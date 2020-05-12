# frozen_string_literal: true

# Handles CRUD actions for Resource objects
# @see Resource
# @see ResourcePolicy
class ResourcesController < ApplicationController
  include PermittedParameters

  before_action :set_resource, only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access, only: %i[show edit update destroy]

  helper_method :resource, :record_filter, :filter_params

  def create
    self.resource = current_organization.resources.new

    if resource.update(resource_params)
      logger.info "Created #{resource}"
      redirect_to resource, notice: "The resource has been created"
    else
      logger.warn "Unable to create resource due to '#{resource.error_sentence}'"
      render :new
    end
  end

  def destroy
    resource.destroy
    redirect_to organization_resources_url(current_organization), notice: "Resource was successfully destroyed."
  end

  def edit
  end

  def index
  end

  def new
    self.resource = current_organization.resources.new(
      name:            "",
      resource_groups: current_organization.resource_groups.default.to_a,
    )
  end

  def show
  end

  def update
    if resource.update(resource_params)
      logger.info "Updated #{resource}"
      redirect_to resource, notice: "The resource has been updated"
    else
      logger.warn "Unable to update resource due to '#{resource.error_sentence}'"
      render :edit
    end
  end

  private

  attr_accessor :resource
  attr_writer :current_organization

  def authorize_general_access
    authorize Resource
  end

  def authorize_unit_access
    authorize(resource)
  end

  def current_organization?
    true
  end

  def filter_params
    params.fetch(:q, {}).permit(*RESOURCE_FILTERS)
  end

  def record_filter
    @record_filter ||= RecordFilter.new(filter_params, pagination_params, current_organization.resources)
  end

  def resources_scope
    current_user.staff? ? Resource : current_user.resources
  end

  def set_resource
    self.resource = resources_scope.find(params[:id])
    self.current_organization = resource.organization
  end
end
