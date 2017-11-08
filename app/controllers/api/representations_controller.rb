module Api
  # Handles API calls for Representations
  class RepresentationsController < Api::ApplicationController
    include PermittedParameters

    before_action :find_representation_and_organization, only: %i[show update destroy]
    before_action :find_resource_and_organization,       only: %i[index]
    before_action :authorize_general_access,             only: %i[index]
    before_action :authorize_unit_access,                only: %i[show update destroy]

    resource_description do 
      short 'Complementary and alternative sensory impressions of a Resource'

      desc <<~DESC
        For a visual resource such as a painting, Coyote can store Representations such as textual descriptions
        or audio recordings of a speaker describing the painting.
      DESC
    end

    api :GET, 'resources/:resource_id/representations', 'Return list of representations for a particular resource ID'
    param_group :pagination, Api::ApplicationController
    def index
      links = { self: request.url }

      render({
        jsonapi: resource.representations.to_a,
        include: %i[resource],
        links: links
      })
    end

    api :GET, 'representations/:id', 'Return attributes of a particular representation'
    def show
      representation = current_user.organization_representations.find(params[:id])

      links = { self: request.url }

      render({
        jsonapi: representation,
        include: %i[resource],
        links: links
      })
    end

    private

    attr_accessor :representation, :resource
    attr_writer :current_organization

    def find_representation_and_organization
      self.representation = current_user.representations.find(params[:id])
      self.current_organization = representation.organization
    end

    def find_resource_and_organization
      self.resource = current_user.resources.find_by!(identifier: params[:resource_identifier])
      self.current_organization = resource.organization
    end

    def authorize_general_access
      authorize(Representation)
    end

    def authorize_unit_access
      authorize(representation)
    end

    def record_filter
      @record_filter ||= RecordFilter.new(filter_params,{},current_user.representations.approved)
    end

    def filter_params
      {} # TODO: will want to support search by metum, context, etc.
    end
  end
end
