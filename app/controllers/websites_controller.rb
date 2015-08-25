class WebsitesController < ApplicationController
  before_filter :admin, only: [:create, :edit, :update, :destroy]
  before_action :set_website, only: [:show, :edit, :update, :destroy, :check_count]

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

    if @website.url.include?("mcachicago")
      limit = 1000
      offset = 0
      url = "https://cms.mcachicago.org/api/v1/attachment_images&offset=#{offset}&limit=#{limit}"
      puts "grabbing images for #{url}"
      begin
        content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
      rescue OpenURI::HTTPError => error
        response = error.io
        puts response.string
        length = 0
      end
      puts content

      begin 
        images = JSON.parse(content)
      rescue Exception => e
        puts "JSON parsing exception"
        length = 0
      end

      length = images.length 

    end

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
