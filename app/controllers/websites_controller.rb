# CRUD actions for adding websites to Organizations
class WebsitesController < ApplicationController
  before_action :authorize_admin!, only: %i[new edit update destroy]
  before_action :set_website, only: %i[show edit update destroy check_count]
  before_action :set_strategies_collection, only: %i[new edit]

  helper_method :website, :websites, :strategies_collection

  respond_to :html, :json

  # GET /websites
  api :GET, "websites", "Get an index of websites"
  def index
  end

  # GET /websites/1
  api :GET, "websites/:id", "Get a website"
  def show
  end

  def check_count
    Rails.cache("website_check_count/#{c.params}",expires_in: 5.minutes) do
      @our_count = @website.images.count
      @their_count = 0

      uniqs = @website.strategy_check_count
      @their_count = uniqs.count

      our_c_ids = @website.images.collect{|i| i.canonical_id}
      @our_count = @website.images.count

      @our_matched_ids = uniqs & our_c_ids
      @our_unmatched_ids =  our_c_ids - uniqs
      @their_unmatched_ids = uniqs - our_c_ids
    end
  end

  # GET /websites/new
  def new
    @website = current_organization.websites.new
  end

  # GET /websites/1/edit
  def edit
  end

  # POST /websites
  # TODO: need to use responders here vs if statements
  def create
    @website = current_organization.websites.new(website_params)

    if @website.save
      if request.format.html?
        logger.info "Created #{@website}"
        redirect_to [current_organization,@website], notice: 'Website was successfully created.'
      else
        logger.warn "Could not create website: '#{@website.errors.full_messages.to_sentence}'"
        render json: @website
      end
    else
      if request.format.html?
        render :new
      else
        render json: { errors: @website.errors.full_messages }
      end
    end
  end

  # PATCH/PUT /websites/1
  def update
    if @website.update(website_params)
      if request.format.html?
        redirect_to [current_organization,@website], notice: 'Website was successfully updated.'
      else
        render @website
      end
    else
      if request.format.html?
        render :edit
      else
        render json: { errors: @website.errors.full_messages }
      end
    end
  end

  # DELETE /websites/1
  def destroy
    @website.destroy
    redirect_to organization_websites_url(current_organization), notice: 'Website was successfully destroyed.'
  end

  private

  attr_accessor :website, :strategies_collection

  def websites
    current_organization.websites
  end

  # Use callbacks to share common setup or constraints between actions
  def set_website
    self.website = current_organization.websites.find(params[:id])
  end

  def set_strategies_collection
    self.strategies_collection = Coyote::Strategies.all.map do |s| 
      s = s.new 
      [s.title, s.class.name]
    end
  end

  # Only allow a trusted parameter "white list" through.
  def website_params
    params.require(:website).permit(:title,:url,:strategy)
  end
end
