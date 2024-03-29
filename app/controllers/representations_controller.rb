# frozen_string_literal: true

# Handles CRUD actions for Representation objects
# @see Representation
# @see RepresentationPolicy
class RepresentationsController < ApplicationController
  include PermittedParameters

  before_action :set_representation, only: %i[show edit update destroy history reject]
  before_action :set_current_resource_and_organization, only: %i[new edit create update]
  before_action :authorize_general_access, only: %i[index]
  before_action :authorize_create_access, only: %i[new create]
  before_action :authorize_unit_access, only: %i[show edit update destroy]

  helper_method :representation, :current_resource, :record_filter, :available_meta, :authors, :licenses

  def create
    self.representation = current_resource.representations.new(representation_params)

    if representation.save
      logger.info "Created #{representation} for #{current_resource}"
      redirect_to representation_path(representation), notice: "The description has been created"
    else
      logger.warn "Unable to create description due to '#{representation.error_sentence}'"
      render :new
    end
  end

  def destroy
    representation.destroy
    redirect_to representations_path, notice: "#{representation} was successfully deleted"
  end

  def edit
  end

  def history
  end

  def index
  end

  def new
    self.representation = current_resource.representations.new({
      language: Rails.configuration.x.default_representation_language,
      author:   current_user,
    })
    representation.metum ||= current_organization.meta.is_required.first
  end

  def reject
  end

  def show
  end

  def update
    if representation.update(representation_params)
      logger.info "Updated #{representation}"
      redirect_to representation_path(representation), notice: "The description has been updated"
    else
      logger.warn "Unable to update description due to '#{representation.error_sentence}'"
      render :edit
    end
  end

  private

  attr_accessor :representation, :current_resource
  attr_writer :current_organization

  def authorize_create_access
    authorize(current_resource, :describe?)
  end

  def authorize_general_access
    authorize Representation
  end

  def authorize_unit_access
    authorize(representation)
  end

  def available_meta
    current_organization.meta
  end

  def current_organization?
    true
  end

  def filter_params
    params.fetch(:q, {}).permit(*REPRESENTATION_FILTERS)
  end

  def record_filter
    @record_filter ||= RecordFilter.new(
      filter_params,
      pagination_params,
      current_organization.representations,
      default_filters: {resource_is_deleted_eq: false},
    )
  end

  def representations_scope
    current_user.staff? ? Representation : current_user.representations
  end

  def set_current_resource_and_organization
    self.current_resource = if representation&.persisted?
      representation.resource
    else
      resource_id = params.require(:resource_id)
      current_organization.resources.find(resource_id)
    end

    self.current_organization = current_resource.organization
  end

  def set_representation
    self.representation = representations_scope.find(params[:id])
    self.current_organization = representation.organization
  end
end
