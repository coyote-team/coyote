# Manges requests to view and manipulate Organization objects
# @see Organization
class OrganizationsController < ApplicationController
  # @!attribute [w] dashboard Dependency injection affordance used for unit testing; normally an instance of Dashboard
  # @see Dashboard
  attr_writer :dashboard
  
  # @!attribute [w] organization Dependency injection affordance used for unit testing; normally an instance of Organization
  # @see organization
  attr_writer :organization

  before_action :set_organization, only: %i[show edit update destroy]

  helper_method :title, :organization, :organizations, :dashboard, :users

  # GET /organizations
  def index
    self.title = "Organizations"
    self.organizations = current_user.organizations
  end

  # GET /organizations/1
  def show
    self.title = organization.title
  end

  # GET /organizations/new
  def new
    self.title = "New Organization"
    self.organization = Organization.new
  end

  # POST /organizations
  def create
    self.title = "Create Organization"
    self.organization = Organization.create(organization_params)

    if organization.valid?
      organization.users << current_user
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
    self.title = "Edit #{organization.title}"
  end

  # PATCH /organizations/1
  def update
    self.title = "Update #{organization.title}"

    if organization.update_attributes(organization_params)
      redirect_to organization, success: "Saved changes to #{organization.title}"
    else
      flash.now[:alert] = "There was an error updating this Organization"
      render action: "edit"
    end
  end

  private

  attr_accessor :title, :organizations
  attr_reader :organization

  def set_organization
    @organization ||= current_user.organizations.find(params[:id])
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

  def users
    organization.users
  end
end
