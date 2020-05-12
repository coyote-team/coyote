# frozen_string_literal: true

# Manges requests to view and manipulate Organization objects
# @see Organization
class OrganizationsController < ApplicationController
  before_action :set_current_organization, only: %i[show edit update] # helps avoid scenario where ActionView::Template::Error can swallow ActiveRecord::RecordNotFound, when a user is not a member of an org
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access, only: %i[show edit update destroy]

  helper_method :current_organization, :organizations, :dashboard, :users

  # POST /organizations
  def create
    self.current_organization = Organization.create(organization_params)

    if current_organization.valid?
      current_organization.memberships.owner.create!(user: current_user)
      logger.info "Created #{current_organization} and assigned #{current_user}"
      redirect_to current_organization, success: "Created #{current_organization.name}"
    else
      logger.warn "Unable to create Organization: #{current_organization.error_sentence}"
      flash.now[:alert] = "There was an error creating this Organization"
      render action: "new"
    end
  end

  # GET /organizations/1/edit
  def edit
  end

  # GET /organizations
  def index
    self.organizations = current_user.organizations
  end

  # GET /organizations/new
  def new
    self.current_organization = Organization.new
  end

  # GET /organizations/1
  def show
  end

  # PATCH /organizations/1
  def update
    if current_organization.update(organization_params)
      redirect_to current_organization, success: "Saved changes to #{current_organization.name}"
    else
      flash.now[:alert] = "There was an error updating this Organization"
      render action: "edit"
    end
  end

  private

  attr_accessor :current_organization, :organizations

  def authorize_general_access
    authorize Organization
  end

  def authorize_unit_access
    authorize(current_organization)
  end

  def current_organization?
    !!current_organization&.persisted?
  end

  def dashboard
    @dashboard ||= Dashboard.new(current_user, current_organization)
  end

  def organization_params
    params.require(:organization).permit(:name)
  end

  def pundit_user
    @pundit_user ||= Coyote::OrganizationUser.new(current_user, current_organization)
  end

  def set_current_organization
    self.current_organization = organization_scope.find(params[:id])
  end
end
