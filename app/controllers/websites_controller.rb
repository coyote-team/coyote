# CRUD actions for adding websites to Organizations
class WebsitesController < ApplicationController
  before_action :set_website,              only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]

  helper_method :title, :website, :websites

  # GET /websites
  def index
    self.title = "Websites for #{current_organization}"
  end

  # GET /websites/1
  def show
    self.title = website.to_s
  end

  # GET /websites/new
  def new
    self.website = current_organization.websites.new
    self.title = "New Website for #{current_organization}"
  end

  # GET /websites/1/edit
  def edit
    self.title = "Edit #{website}"
  end

  # POST /websites
  def create
    self.website = current_organization.websites.new(website_params)

    if website.save
      logger.info "Created #{website}"
      redirect_to [current_organization,website], notice: 'Website was successfully created.'
    else
      logger.warn "Could not create website: '#{website.error_sentence}'"
      self.title = 'Error creating new website'
      render :new
    end
  end

  # PATCH/PUT /websites/1
  def update
    if website.update(website_params)
      logger.info "Updated #{website}"
      redirect_to [current_organization,website], notice: 'Website was successfully updated.'
    else
      logger.warn "Unable to update #{website}: '#{website.error_sentence}'"
      self.title = "Error updating #{website}"
      render :edit
    end
  end

  # DELETE /websites/1
  def destroy
    website.destroy
    logger.info "Destroyed #{website}"
    redirect_to organization_websites_url(current_organization), notice: 'Website was successfully destroyed.'
  end

  private

  attr_accessor :title, :website

  def websites
    current_organization.websites
  end

  def set_website
    self.website = current_organization.websites.find(params[:id])
  end

  def website_params
    params.require(:website).permit(:title,:url,:strategy)
  end

  def authorize_general_access
    authorize Website
  end

  def authorize_unit_access
    authorize(website)
  end
end
