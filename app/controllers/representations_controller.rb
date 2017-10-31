# Handles CRUD actions for Representation objects
# @see Representation
# @see RepresentationPolicy
class RepresentationsController < ApplicationController
  include PermittedParameters

  before_action :set_representation,       only: %i[show edit update destroy]
  before_action :set_current_resource,     only: %i[new create]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]
  
  helper_method :representation, :current_resource, :record_filter, :available_meta, :authors, :licenses

  def index
  end

  def show
  end

  def new
    self.representation = current_resource.representations.new(language: Rails.configuration.x.default_representation_language)
  end

  def edit
  end

  def create
    self.representation = current_resource.representations.new(representation_params)
    representation.author = current_user

    if representation.save
      logger.info "Created #{representation}"
      redirect_to [current_organization,representation], notice: 'The representation has been created'
    else
      logger.warn "Unable to create representation due to '#{representation.error_sentence}'"
      render :new
    end
  end

  def update
    if representation.update(representation_params)
      logger.info "Updated #{representation}"
      redirect_to [current_organization,representation], notice: 'The representation has been updated'
    else
      logger.warn "Unable to update representation due to '#{representation.error_sentence}'"
      render :edit
    end
  end

  def destroy
    representation.destroy
    redirect_to organization_representations_url(current_organization), notice: 'Representation was successfully destroyed.'
  end

  private

  attr_accessor :representation, :current_resource

  def record_filter
    @record_filter ||= RecordFilter.new(filter_params,pagination_params,current_organization.representations)
  end

  def filter_params
    params.fetch(:q,{}).permit(:text_cont_all,:status_eq,:metum_id_eq,:author_id_in)
  end

  def set_representation
    self.representation = current_organization.representations.find(params[:id])
  end

  def set_current_resource
    resource_id = params.require(:resource_id)
    self.current_resource = current_organization.resources.find(resource_id)
  end

  def available_meta
    current_organization.meta
  end

  def authorize_general_access
    authorize Representation
  end

  def authorize_unit_access
    authorize(representation)
  end
end
