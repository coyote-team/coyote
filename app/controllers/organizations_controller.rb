# Manges requests to view and manipulate Organization objects
# @see Organization
class OrganizationsController < ApplicationController
  # @!attribute [w] dashboard Dependency injection affordance used for unit testing; normally an instance of Dashboard
  # @see Dashboard
  attr_writer :dashboard

  helper_method :title, :organizations, :current_organization, :dashboard

  # GET /organizations
  def index
    self.title = "Organizations"
    self.organizations = current_user.organizations
  end

  # GET /organizations/1
  def show
    self.title = current_organization.title
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
      redirect_to organization, success: "Created #{organization.title}"
    else
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

  attr_accessor :title, :organizations, :current_organization

  def organization_params
    params.require(:organization).permit(:title)
  end

  def current_organization
    # overrides ApplicationController method which works in nested resource contexts
    @current_organization ||= current_user.organizations.find(params[:id])
  end

  def dashboard
    @dashboard ||= Dashboard.new(current_user,current_organization)
  end
end
