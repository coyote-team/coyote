# Manges requests to view and manipulate Organization objects
# @see Organization
class OrganizationsController < ApplicationController
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]
  
  helper_method :organization, :organizations, :dashboard, :users

  # GET /organizations
  def index
    self.organizations = current_user.organizations
  end

  # GET /organizations/1
  def show
  end

  # GET /organizations/new
  def new
    self.organization = Organization.new
  end

  # POST /organizations
  def create
    self.organization = Organization.create(organization_params)

    if organization.valid?
      organization.memberships.owner.create!(user: current_user)
      logger.info "Created #{organization} and assigned #{current_user}"
      redirect_to organization, success: "Created #{organization.title}"
    else
      logger.warn "Unable to create Organization: #{organization.error_sentence}"
      flash.now[:alert] = "There was an error creating this Organization"
      render action: "new"
    end
  end

  # GET /organizations/1/edit
  def edit
  end

  # PATCH /organizations/1
  def update
    if organization.update_attributes(organization_params)
      redirect_to organization, success: "Saved changes to #{organization.title}"
    else
      flash.now[:alert] = "There was an error updating this Organization"
      render action: "edit"
    end
  end

  private

  attr_writer :organization
  attr_accessor :organizations

  def organization
    @organization ||= current_user.organizations.find_by(id: params[:id])
  end

  def pundit_user
    # necessary to override ApplicationController's method here because in this controller we may not be dealing with a particular organization
    @pundit_user ||= Coyote::OrganizationUser.new(current_user,organization)
  end

  def organization_params
    params.require(:organization).permit(:title)
  end

  # overrides ApplicationController method which works in nested resource contexts
  def current_organization_id
    params[:id]
  end

  def dashboard
    @dashboard ||= Dashboard.new(current_user,organization)
  end

  def authorize_general_access
    authorize Organization
  end

  def authorize_unit_access
    authorize(organization)
  end
end
