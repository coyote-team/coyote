# Handles CRUD actions for Resource objects
# @see Resource
# @see ResourcePolicy
class ResourcesController < ApplicationController
  include PermittedParameters

  before_action :set_resource,             only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]

  helper_method :resource, :record_filter

  def index
  end

  def show
  end

  def new
    self.resource = current_organization.resources.new(title: '')
  end

  def edit
  end

  def create
    self.resource = current_organization.resources.new(resource_params)

    if resource.save
      logger.info "Created #{resource}"
      redirect_to [current_organization,resource], notice: 'The resource has been created'
    else
      logger.warn "Unable to create resource due to '#{resource.error_sentence}'"
      render :new
    end
  end

  def update
    if resource.update(resource_params)
      logger.info "Updated #{resource}"
      redirect_to [current_organization,resource], notice: 'The resource has been updated'
    else
      logger.warn "Unable to update resource due to '#{resource.error_sentence}'"
      render :edit
    end
  end

  def destroy
    resource.destroy
    redirect_to organization_resources_url(current_organization), notice: 'Resource was successfully destroyed.'
  end

  private

  attr_accessor :resource

  def record_filter
    @record_filter ||= RecordFilter.new(params,current_organization.resources)
  end

  def set_resource
    self.resource = current_organization.resources.find(params[:id])
  end

  def authorize_general_access
    authorize Resource
  end

  def authorize_unit_access
    authorize(resource)
  end
end
