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
      redirect_to resource, notice: 'The resource has been created'
    else
      logger.warn "Unable to create resource due to '#{resource.error_sentence}'"
      render :new
    end
  end

  def update
    if resource.update(resource_params)
      logger.info "Updated #{resource}"
      redirect_to resource, notice: 'The resource has been updated'
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
  attr_writer :current_organization

  def record_filter
    @record_filter ||= RecordFilter.new(filter_params,pagination_params,current_organization.resources.by_priority)
  end

  def filter_params
    params.fetch(:q,{}).permit(:identifier_or_title_or_representations_text_cont_all,:representations_author_id_eq,:scope,:assignments_user_id_eq)
  end

  def set_resource
    self.resource = current_user.resources.find(params[:id])
    self.current_organization = resource.organization
  end

  def current_organization?
    true
  end

  def authorize_general_access
    authorize Resource
  end

  def authorize_unit_access
    authorize(resource)
  end
end
