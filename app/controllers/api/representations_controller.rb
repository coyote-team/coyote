# frozen_string_literal: true

module Api
  # Handles API calls for Representations
  class RepresentationsController < Api::ApplicationController
    include PermittedParameters

    before_action :find_representation, only: %i[show update destroy]
    before_action :find_resource, only: %i[index]
    before_action :authorize_general_access, only: %i[index]
    before_action :authorize_unit_access, only: %i[show update destroy]

    resource_description do
      short "Complementary and alternative sensory impressions of a Resource"

      desc <<~DESC
        For a visual resource such as a painting, Coyote can store Representations such as textual descriptions
        or audio recordings of a speaker describing the painting.
      DESC
    end

    api :GET, "resources/:resource_id/representations", "Return list of representations for a particular resource ID"
    def index
      links = {self: request.url}

      representations = record_filter.records

      render({
        jsonapi: representations.to_a,
        include: %i[resource],
        links:   links,
      })
    end

    api :GET, "representations/:id", "Return attributes of a particular representation"
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
      @record_filter ||= RecordFilter.new(filter_params, pagination_params, resource.representations, default_order: :by_ordinality)
    end
  end
end
