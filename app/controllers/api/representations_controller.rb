# frozen_string_literal: true

module Api
  # Handles API calls for Representations
  class RepresentationsController < Api::ApplicationController
    include PermittedParameters

    before_action :find_representation, only: %i[show]
    before_action :find_resource, only: %i[create index]
    before_action :authorize_general_access, only: %i[index]
    before_action :authorize_unit_access, only: %i[show]

    resource_description do
      short "Complementary and alternative sensory impressions of a Resource"
      desc <<~DESC
        For a visual resource such as a painting, Coyote can store Representations such as textual descriptions
        or audio recordings of a speaker describing the painting.
      DESC
      formats %w[json]
    end

    # Define a param group for how we return representations
    serializes serializable_representation.tap { |representation| representation.resource = serializable_resource }, {
      include: %i[resource],
    }

    representation_params = representation_params_builder
    def_param_group :representation do
      param(:representation, Hash, action_aware: true, &representation_params)
    end

    api! "Create a new representation"
    param_group :representation
    returns_serialized :representation
    def create
      resource_params = clean_resource_params(representations: [representation_params])
      updated = resource.update(resource_params)
      representation = resource.new_representations.first
      if updated
        logger.info "Created #{representation}"
        render({
          jsonapi: representation,
          status:  :created,
          links:   {
            coyote: resource_url(resource, organization_id: resource.organization_id),
          },
          include: %i[resource],
        })
      else
        logger.warn "Unable to create representation due to '#{representation.error_sentence}'"
        render jsonapi_errors: representation.errors, status: :unprocessable_entity
      end
    end

    api! "Return list of representations for a particular resource ID"
    returns_serialized array_of: :representation
    def index
      links = {self: request.url}

      representations = record_filter.records

      render({
        jsonapi: representations.to_a,
        include: %i[resource],
        links:   links,
      })
    end

    api! "Return attributes of a particular representation"
    returns_serialized :representation
    def show
      representation = current_user.organization_representations.find(params[:id])

      links = {self: request.url, coyote: representation_url(representation)}

      render({
        jsonapi: representation,
        include: %i[resource],
        links:   links,
      })
    end

    private

    attr_accessor :representation, :resource

    def authorize_general_access
      authorize(Representation)
    end

    def authorize_unit_access
      authorize(representation)
    end

    def filter_params
      params.fetch(:filter, {}).permit(*REPRESENTATION_FILTERS)
    end

    def find_representation
      self.representation = current_user.representations.find(params[:id])
      self.current_organization = representation.organization
    end

    def record_filter
      @record_filter ||= RecordFilter.new(filter_params, pagination_params, resource.representations, default_order: :by_status_and_ordinality)
    end
  end
end
