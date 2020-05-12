# frozen_string_literal: true

# Handles requests for ResourceGroup information
# @see ResourceGroup
class ResourceGroupsController < ApplicationController
  before_action :set_resource_group, only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access, only: %i[show edit update destroy]

  helper_method :resource_group, :resource_groups

  # POST /resource_groups
  def create
    self.resource_group = current_organization.resource_groups.new(resource_group_params)

    if resource_group.save
      logger.info "Created #{resource_group}"
      redirect_to [current_organization, resource_group], notice: "Resource Group was successfully created."
    else
      logger.warn "Unable to create resource_group: '#{resource_group.error_sentence}'"
      render :new
    end
  end

  # DELETE /resource_groups/1
  def destroy
    if resource_group.destroy
      flash[:notice] = "Resource Group was successfully destroyed."
    else
      msg = "Unable to destroy #{resource_group}: #{resource_group.error_sentence}"
      logger.warn msg
      flash[:error] = msg
    end

    redirect_to organization_resource_groups_url(current_organization)
  end

  # GET /resource_groups/1/edit
  def edit
  end

  # GET /resource_groups
  def index
  end

  # GET /resource_groups/new
  def new
    self.resource_group = current_organization.resource_groups.new
  end

  # GET /resource_groups/1
  def show
  end

  # PATCH/PUT /resource_groups/1
  def update
    if resource_group.update(resource_group_params)
      redirect_to [current_organization, resource_group], notice: "Resource Group was successfully updated."
    else
      logger.warn "Unable to update #{resource_group}: #{resource_group.error_sentence}"
      render :edit
    end
  end

  private

  attr_accessor :resource_group

  def authorize_general_access
    authorize ResourceGroup
  end

  def authorize_unit_access
    authorize(resource_group)
  end

  def resource_group_params
    params.require(:resource_group).permit(:name, :webhook_uri)
  end

  def resource_groups
    @resource_groups ||= current_organization.resource_groups.by_default_and_name
  end

  def set_resource_group
    @resource_group = current_organization.resource_groups.find(params[:id])
  end
end
