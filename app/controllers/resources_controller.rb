# frozen_string_literal: true

# Handles CRUD actions for Resource objects
# @see Resource
# @see ResourcePolicy
class ResourcesController < ApplicationController
  include PermittedParameters

  before_action :check_for_canonical_id, only: %i[show]
  before_action :set_resource, only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access, only: %i[show edit update destroy]

  helper_method :resource, :record_filter, :filter_params, :resource_groups

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
    resource.mark_as_deleted!
    redirect_to resources_path, notice: "#{resource} was deleted"
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

  def update_many
    resource_ids = params[:resource_ids]
    if resource_ids.present?
      resources = policy(Resource).scope.where(id: params[:resource_ids])
      resources.update(many_resources_params)
      flash[:notice] = "Your changes were applied!"
    end

    redirect_back(fallback_location: resources_path)
  end

  private

  attr_accessor :resource
  attr_writer :current_organization

  def authorize_general_access
    authorize Resource
  end

  def authorize_unit_access
    authorize(resource)
    if resource.soft_deleted? && !current_user.staff?
      raise ActiveRecord::RecordNotFound
    end
  end

  def check_for_canonical_id
    if params[:canonical_id]
      resource = current_organization.resources.find_by!(canonical_id: params[:canonical_id])
      redirect_to resource_path(resource)
    end
  end

  def current_organization?
    true
  end

  def filter_params
    params.fetch(:q, {}).permit(*RESOURCE_FILTERS)
  end

  def many_resources_params
    params.require(:resource).permit(:assign_to_user_id, :resource_group_id, :union_resource_groups)
  end

  def record_filter
    @record_filter ||= RecordFilter.new(
      filter_params, pagination_params, current_organization.resources,
      default_filters: {is_deleted_eq: false},
      default_order:   ["by_name"]
    )
  end

  def resource_groups
    @resource_groups ||= ResourceGroup.all
  end

  def set_resource
    self.resource = current_organization.resources.find(params[:id])
    self.current_organization = resource.organization
  end
end
