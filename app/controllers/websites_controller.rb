class WebsitesController < ApplicationController
  before_filter :admin, only: [:create, :edit, :update, :destroy]
  before_action :set_website, only: [:show, :edit, :update, :destroy, :check_count]
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
    require 'multi_json'
    require 'open-uri'

    @our_count = @website.images.count
    @their_count = 0
    ids = []
    if @website.url.include?("mcachicago")
      limit = 1000
      #our_divmod = @our_count.divmod(limit)
      #offset = our_divmod[0] * limit
      offset = 0
      length = 1 
      while length != 0 do
        url = "https://mcachicago.org/api/v1/attachment_images?offset=#{offset}&limit=#{limit}"
        Rails.logger.info "grabbing images for #{url}"

        begin
          content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
        rescue OpenURI::HTTPError => error
          response = error.io
          Rails.logger.error response.string
          length = 0
        end

        begin 
          images = JSON.parse(content)
        rescue Exception => e
          Rails.logger.error "JSON parsing exception"
          Rails.logger.error e
          length = 0
        end

        Rails.logger.info "count of images here is: #{images.count}"
        ids.push images.collect{|i| i["id"]}

        if images and images.length
          length = images.length 
          offset += limit
        else
          length = 0
        end
      end
    end

    ids.flatten!
    ids.compact!

    #Rails.logger.info "Their count #{@their_count}"
    
    @uniqs = ids.uniq
    @their_count = @uniqs.count

    #@dupes  = ids - @uniqs
    #@their_dupe_count = @dupes.count
    
    @our_c_ids = @website.images.collect{|i| i.canonical_id}
    @our_matched_ids = @uniqs & @our_c_ids
    @our_unmatched_ids =  @our_c_ids - @uniqs
    @their_unmatched_ids = @uniqs - @our_c_ids
    
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
      redirect_to @website, notice: 'Website was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /websites/1
  def update
    if @website.update(website_params)
      redirect_to @website, notice: 'Website was successfully updated.'
    else
      render :edit
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

    # Only allow a trusted parameter "white list" through.
    def website_params
      params.require(:website).permit(:title, :url)
    end
end
