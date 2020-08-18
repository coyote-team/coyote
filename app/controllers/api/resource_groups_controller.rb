# frozen_string_literal: true

module Api
  # Handles calls to /api/v1/resource_groups/
  class ResourceGroupsController < Api::ApplicationController
    before_action :find_resource_group, only: %i[destroy show update]
    before_action :authorize_general_access, only: %i[index create]
    before_action :authorize_unit_access, only: %i[destroy show update]

    resource_description do
      short "Used to organize resources into one or more groups"
    end

    serializes serializable_resource_group.tap { |group| group.resources = [serializable_resource.tap { |resource| resource.representations = [serializable_representation.tap { |representation| representation.resource = serializable_resource }] }] }, {
      include: %i[resource],
    }

    def_param_group :resource_group do
      param :resource_group, Hash, action_aware: true do
        param :name, String, "Caption that helps humans identify the resource", required: true
        param :webhook_uri, String, "A webhook endpoint that should receive periodic POST requests containing information about resources in this resource group that have changed"
      end
    end

    api! "Create a resource group for the given organization"
    param_group :resource_group
    returns_serialized :resource_group
    def create
      resource_group = current_organization.resource_groups.new(resource_group_params)

      if resource_group.save
        logger.info "Created #{resource_group}"
        render_resource_group(resource_group, status: :created, links: {
          coyote: resource_group_url(resource_group, organization_id: resource_group.organization),
        })
      else
        logger.warn "Unable to create resource group due to '#{resource_group.error_sentence}'"
        render jsonapi_errors: resource_group.errors, status: :unprocessable_entity
      end
    end

    api! "Delete the resource group"
    def destroy
      if resource_group.destroy
        head :no_content
      else
        render jsonapi_errors: resource_group.errors, status: :unprocessable_entity
      end
    end

    api! "List resource groups for the given organization"
    returns_serialized array_of: :resource_group
    def index
      links = {self: request.url}
      render_resource_group(current_organization.resource_groups, links: links)
    end

    api! "Return the resource group description"
    returns_serialized :resource_group
    def show
      render_resource_group(resource_group)
    end

    api! "Update a resource group"
    param_group :resource_group
    returns_serialized :resource_group
    def update
      if resource_group.update(resource_group_params)
        logger.info "Updated #{resource_group}"
        render_resource_group(resource_group, links: {
          coyote: resource_group_url(resource_group, organization_id: resource_group.organization),
        })
      else
        logger.warn "Unable to update resource group due to '#{resource_group.error_sentence}'"
        render jsonapi_errors: resource_group.errors, status: :unprocessable_entity
      end
    end

    private

    attr_accessor :resource_group

    def authorize_general_access
      authorize(ResourceGroup)
    end

    def authorize_unit_access
      authorize(resource_group)
    end

    def find_resource_group
      self.resource_group = current_user.resource_groups.find(params[:resource_group_id] || params[:id])
      self.current_organization = params[:organization_id] ? current_organization : resource_group.organization
    end

    def render_resource_group(resource_group, options = {})
      # First, we're rendering whatever we were passed
      options[:jsonapi] = resource_group

      # However, we are tacking on the 'token' to the attributes in resource_groups
      options[:fields] ||= {}
      fields = options[:fields].delete(:resource_groups) { [] }
      options[:fields][:resource_groups] = fields.union(SerializableResourceGroup::ATTRIBUTES + [:token])

      # Finally, render all the JSONAPI stuff
      render options
    end

    def resource_group_params
      params.require(:resource_group).permit(
        :name,
        :webhook_uri,
      )
    end
  end
end
