# frozen_string_literal: true

module Api
  # Handles calls to /api/v1/resources/
  class ResourcesController < Api::ApplicationController
    include PermittedParameters

    before_action :authorize_general_access, only: %i[index create create_many]

    before_action :find_resource, only: %i[destroy show update]
    before_action :authorize_unit_access, only: %i[destroy show update]

    resource_description do
      short "Anything with an identity that can be represented in the Coyote database"

      desc <<~DESC
        We use the Dublin Core meaning for what a Resource represents: "...a resource is anything that has identity. Familiar examples include an electronic document, an image,
        a service (e.g., "today's weather report for Los Angeles"), and a collection of other resources. Not all resources are network "retrievable"; e.g., human beings,
        corporations, and bound books in a library can also be considered resources."
      DESC

      formats %w[json]
    end

    representation_params = representation_params_builder
    resource_params = -> {
      param :name, String, "Caption that helps humans identify the resource", required: true
      param :source_uri, String, "The canonical location of the resource", required: true
      param :canonical_id, String, "Unique identifier assigned by the organization that owns this resource"
      param :host_uris, Array, "A list of URIs that feature this resource"
      param :priority_flag, [true, false], "Indicates this is a high-priority resource when `true`"
      param :resource_group_id, Integer, "Identifies the resource group to which this resource belongs. If omitted, will be set to the default resource group for this organization."
      param :resource_group_ids, Array, "Identifies multiple resource groups to which this resource belongs. This will overwrite all other resource groups unless `union_resource_groups` is set to `true`"
      param(:representations, Array, "An array of representations you'd like attached to this resource. See the `representations` for more info.", action_aware: true, &representation_params)
      param :union_host_uris, [true, false], "Append new host URIs rather than replace them. This defaults to `true` on the bulk upsert endpoint and cannot be disabled there.", required: false
      param :union_resource_groups, [true, false], "Append new resource groups rather than replace them. This defaults to `true` on the bulk upsert endpoint and cannot be disabled there.", required: false
    }

    # Define a param group for how we return representations
    serializes serializable_resource.tap { |resource| resource.representations = [serializable_representation] }, {
      include: %i[organization representations],
    }

    def_param_group :resource do
      param(:resource, Hash, action_aware: true) { instance_exec(&resource_params) }
    end

    api! "Create a new resource"
    param_group :resource
    returns_serialized :resource
    def create
      resource = resource_for(resource_params)
      if resource.update(resource_params)
        logger.info "Created #{resource}"
        render jsonapi: resource,
               status:  :created,
               links:   {
                 coyote: resource_url(resource, organization_id: resource.organization_id),
               },
               include: %i[organization representations]
      else
        logger.warn "Unable to create resource due to '#{resource.error_sentence}'"
        render jsonapi_errors: resource.errors, status: :unprocessable_entity
      end
    end

    api! "Bulk 'upsert' resources by source_uri"
    param(:resources, Array) { instance_exec(&resource_params) }
    returns_serialized array_of: :resource
    def create_many
      failures = []
      successes = []
      params.require(:resources).each do |(key, resource_params)|
        resource_params ||= key
        resource_params = clean_resource_params(resource_params)
        resource = resource_for(resource_params)
        resource.union_host_uris = true
        resource.union_resource_groups = true
        if resource.update(resource_params)
          successes.push(resource)
        else
          failures.push(resource)
        end
      end

      render jsonapi_mixed: [successes, failures],
             include:       %i[representations],
             status:        failures.any? ? :unprocessable_entity : :created
    end

    api! "Delete existing resource"
    def destroy
      resource.mark_as_deleted!
      head :no_content
    end

    api! "Return a list of resources available to the authenticated user"
    param_group :pagination, Api::ApplicationController
    param :filter, Hash do
      param :canonical_id_or_name_or_representations_text_cont_all, String, "Search Resource canonical ID, name, or associated Representation text for this value"
      param :representations_updated_at_gt, Date, "Filter returned resources to those with representations having an `updated_at` value after the given date"
      param :updated_at_gt, Date, "Filter returned resources to those whose `updated_at` value is after the given date"
      param :scope, Resource.ransackable_scopes.to_a, "Limit search to Resources in these states"
    end
    returns_serialized array_of: :resource
    def index
      links = {self: request.url}

      resources = record_filter.records

      record_filter.pagination_link_params.each do |rel, link_params|
        link = api_resources_url(link_params)
        links[rel] = link
      end

      render({
        jsonapi: resources.to_a,
        include: %i[organization representations],
        links:   links,
      })
    end

    api! "Return attributes of a particular resource"
    param_group :resource
    returns_serialized :resource
    def show
      render({
        jsonapi: resource,
        include: %i[organization representations],
      })
    end

    api! "Update attributes of a particular resource"
    returns_serialized :resource
    def update
      if resource.update(resource_params)
        logger.info "Updated #{resource}"
        render jsonapi: resource, links: {
          coyote: resource_url(resource, organization_id: resource.organization_id),
        }
      else
        logger.warn "Unable to update resource due to '#{resource.error_sentence}'"
        render jsonapi_errors: resource.errors, status: :unprocessable_entity
      end
    end

    private

    attr_accessor :resource

    def authorize_general_access
      authorize(Resource)
    end

    def authorize_unit_access
      authorize(resource)
    end

    def filter_params
      params.fetch(:filter, {}).permit(*RESOURCE_FILTERS)
    end

    def record_filter
      @record_filter ||= RecordFilter.new(
        filter_params,
        pagination_params,
        (current_organization || current_user).resources,
        default_filters: {is_deleted_eq: false},
        default_order:   :order_by_priority_and_date,
      )
    end

    def resource_for(resource_params)
      current_organization.resources.find_or_initialize_by_canonical_id_or_source_uri(resource_params)
    end
  end
end
