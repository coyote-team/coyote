class WebsitesController < ApplicationController
  before_filter :admin, only: [:create, :edit, :update, :destroy]
  before_action :set_website, only: [:show, :edit, :update, :destroy, :check_count]
  before_action :set_strategies_collection, only: [:new, :edit]
  before_filter :users

  caches_action :check_count, :cache_path => { :cache_path => Proc.new { |c| c.params } }, :expires_in => 5.minutes

  respond_to :html, :json

  # GET /websites
  api :GET, "websites", "Get an index of websites"
  def index
    @websites = Website.all
  end

  # GET /websites/1
  api :GET, "websites/:id", "Get a website"
  def show
  end

  def check_count
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

  # GET /websites/new
  def new
    @website = Website.new
  end

  # GET /websites/1/edit
  def edit
  end

  # POST /websites
  def create
    @website = Website.new(website_params)

    if @website.save
      if request.format.html?
        redirect_to @website, notice: 'Website was successfully created.'
      else
        render :json => @website.to_json
      end
    else
      if request.format.html?
        render :new
      else
        render :json => { :errors => @website.errors.full_messages }
      end
    end
  end

  # PATCH/PUT /websites/1
  def update
    if @website.update(website_params)
      if request.format.html?
        redirect_to @website, notice: 'Website was successfully updated.'
      else
        render @website
      end
    else
      if request.format.html?
        render :edit
      else
        render :json => { :errors => @website.errors.full_messages }
      end
    end
  end

  # DELETE /websites/1
  def destroy
    @website.destroy
    redirect_to websites_url, notice: 'Website was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_website
      @website = Website.find(params[:id])
    end

    def set_strategies_collection
      @strategies_collection = Strategy.subclasses.map{|s| s = s.new; [s.title, s.class.name]}
    end

    # Only allow a trusted parameter "white list" through.
    def website_params
      params.require(:website).permit(:title, :url, :strategy)
    end
end
