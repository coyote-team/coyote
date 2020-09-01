# frozen_string_literal: true

# Mediates CRUD actions for ResourceLink objects
# @see ResourceLink
# @see ResourceLinkPolicy
class ResourceLinksController < ApplicationController
  before_action :set_resource_link, only: %i[show edit update destroy]
  before_action :authorize_access, only: %i[show edit update destroy]

  helper_method :resource_link

  def create
    subject_resource_id = resource_link_params.fetch(:subject_resource_id)
    verb = resource_link_params.fetch(:verb)
    object_resource_id = resource_link_params.fetch(:object_resource_id)

    subject_resource = current_organization.resources.find(subject_resource_id)
    object_resource = current_organization.resources.find(object_resource_id)

    self.resource_link = ResourceLink.find_or_initialize_by({
      subject_resource: subject_resource,
      verb:             verb,
      object_resource:  object_resource,
    })

    authorize(resource_link)

    if resource_link.save
      logger.info "Created #{resource_link}"
      redirect_to resource_link, notice: "The Resource Link has been created"
    else
      logger.warn "Unable to create Resource Link due to '#{resource_link.error_sentence}'"
      render :new
    end
  end

  def destroy
    resource_link.destroy
    redirect_to resource_link.subject_resource, notice: "Resource Link was successfully deleted."
  end

  def edit
  end

  def new
    subject_resource = current_organization.resources.find(params.require(:subject_resource_id))
    self.resource_link = ResourceLink.new(subject_resource: subject_resource)
    authorize(resource_link)
  end

  def show
  end

  def update
    if resource_link.update(resource_link_params)
      logger.info "Updated #{resource_link}"
      redirect_to resource_link, notice: "The Resource Link has been updated"
    else
      logger.warn "Unable to update Resource Link due to '#{resource_link.error_sentence}'"
      render :edit
    end
  end

  private

  attr_accessor :resource_link

  def authorize_access
    authorize(resource_link)
  end

  def pundit_user
    Coyote::OrganizationUser.new(current_user, resource_link.subject_resource_organization)
  end

  def resource_link_params
    params.require(:resource_link).permit(:subject_resource_id, :verb, :object_resource_id)
  end

  def set_resource_link
    self.resource_link = ResourceLink.where(subject_resource: current_organization.resources)
      .or(ResourceLink.where(object_resource: current_organization.resources))
      .find(params[:id])
  end
end
