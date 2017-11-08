module Api
  # Handles calls to /api/v1/resources/
  class ResourcesController < Api::ApplicationController
    include PermittedParameters

    before_action :find_resource,            only: %i[show update destroy]
    before_action :authorize_general_access, only: %i[index create]
    before_action :authorize_unit_access,    only: %i[show update destroy]

    resource_description do 
      short 'Anything that can be represented by Coyote'

      desc <<~DESC
        We use the Dublin Core meaning for what a Resource represents: "...a resource is anything that has identity. Familiar examples include an electronic document, an image, 
        a service (e.g., "today's weather report for Los Angeles"), and a collection of other resources. Not all resources are network "retrievable"; e.g., human beings, 
        corporations, and bound books in a library can also be considered resources."
      DESC
    end

    def_param_group :resource do
      param :resource, Hash, action_aware: true do
        param :identifier, String, 'Unique identifier for this resource', required: true
        param :title, String, required: false
        param :resource_type, String, 'Dublin Core Metadata type for this resource', required: true
        param :canonical_id, String, 'Unique identifier assigned by the organization that owns this resource', required: true
        param :source_uri, String, 'The canonical location of the resource', required: false
        param :context, String, 'Identifies the organizationl context to which this resource belongs', required: true
        param :organization_id, Integer, 'Identifies which organization owns the resource', required: true
      end
    end

    api :GET, 'resources', 'Return a list of resources available to the authenticated user'
    param_group :pagination, Api::ApplicationController
    param :filter, Hash do
      param :identifier_or_title_or_representations_text_cont_all, String, 'Search Resource identifier, title, or associated Representation text for this value'
      param :scope, Resource.ransackable_scopes, 'Limit search to Resources in these states'
    end
    def index
      links = { self: request.url }

      resources = record_filter.records

      record_filter.pagination_link_params.each do |rel,link_params|
        link = api_resources_url(link_params)
        links[rel] = link
      end

      render({
        jsonapi: resources.to_a,
        include: %i[organization representations],
        links: links
      })
    end

    api :GET, 'resources/:id', 'Return attributes of a particular resource'
    def show
      render({
        jsonapi: resource,
        include: %i[organization representations]
      })
    end

    api :POST, 'resources', 'Create a new resource'
    param_group :resource
    def create
      context_id = resource_params.delete(:context_id)
      context = current_user.contexts.find(context_id)

      resource = current_organization.resources.new(resource_params)
      resource.context = context

      if resource.save
        logger.info "Created #{resource}"
        render :jsonapi => resource, :status => :created
      else
        logger.warn "Unable to create resource due to '#{resource.error_sentence}'"
        render :jsonapi_errors => resource.errors, :status => :unprocessable_entity
      end
    end

    private

    attr_accessor :resource
    attr_writer :current_organization

    def find_resource
      self.resource = current_user.resources.find_by!(identifier: params[:id])
      self.current_organization = resource.organization
    end

    def authorize_general_access
      authorize(Resource)
    end

    def authorize_unit_access
      authorize(resource)
    end

    def record_filter
      @record_filter ||= RecordFilter.new(filter_params,pagination_params,current_user.resources)
    end

    def filter_params
      params.fetch(:filter,{}).permit(:identifier_or_title_or_representations_text_cont_all,:scope)
    end
  end
end
