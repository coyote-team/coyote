# Manges requests to view and manipulate Organization objects
# @see Organization
class OrganizationsController < ApplicationController
  before_action :find_organization, only: %i[show edit update delete]

  helper_method :title, :organizations, :organization

  # GET /organizations
  def index
    self.title = "Organizations"
    self.organizations = Organization.all.page(params[:page]) # TODO: scope this by User memberships
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

  attr_accessor :title, :organizations, :organization

  def organization_params
    params.require(:organization).permit(:title)
  end

  def find_organization
    self.organization = Organization.find(params[:id])
  end
end
