class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_action :clear_search, only: [:index]
  before_action :get_users, only: [:index, :show], unless: -> { request.xhr? }

  before_action :admin, only: [:create, :edit, :update, :destroy]

  respond_to :html, :json

  def_param_group :image do
    param :image, Hash do
      param :canonical_id,  String , required: true
      param :path,           String , required: true
      param :website_id,    :number, required: true
      param :group_id,      :number, required: true
      param :created_at,    DateTime
      param :updated_at,    DateTime
    end
  end

  # GET /images
  param :page, :number
  param :canonical_id,  String , optional: true
  param :status_ids, Array, optional: true
  api :GET, "images", "Get an index of images"
  description  <<-EOT
If the result is multiple images, this endpoints returns an index object with <code>_metadata</code> and <code>results</code>.
If the params include <code>canonical_id</code>, an object is returned in the style of <code>GET</code> <code>/images/1</code>.

<code>status_id[]</code> can be used to filter the descriptions array. The default is <code>[2]</code> for the public view.

<code>status_id[]</code> values can include:

- 1 : "Ready to review"
- 2 : "Approved"
- 3 : "Not approved"

Accordingly, <code>status_id[]=1&status_id[]=2</code> should be used in the CMS view.

The image JSON also includes the text of the most recent English <code>alt</code> and <code>long</code> as filtered by the <code>status_id</code>. If an approved description is available, it will be supplied instead of any ready to review descriptions when <code>status_id[]=1&status_id[]=2</code> is requested.
  EOT
  def index
    if params[:canonical_id].present? 

      #for ajax
      @image = Image.find_by(canonical_id: params[:canonical_id])

    else

      @q = Image.ransack(search_params)

      if params[:tag].present? 
        @images = Image.tagged_with(params[:tag]).page(params[:page]) 
      else
        @images = @q.result(distinct: true).page(params[:page]) 
      end

      if request.format.html?
        @tags = Rails.cache.fetch('tags', expires_in: 15.minutes) do
          Image.tag_counts_on(:tags)
        end
      end

    end


    @status_ids = [2]
    @status_ids = params[:status_ids]  if params[:status_ids]
  end

  # GET /images/1
  api :GET, "images/:id", "Get an image"
  param :status_ids, Array, optional: true
  description  <<-EOT
<code>status_ids[]</code> can be used to filter the descriptions array. The default is <code>[2]</code> for the public view.

<code>status_ids[]</code> values can include:

- 1 : "Ready to review"
- 2 : "Approved"
- 3 : "Not approved"

Accordingly, <code>status_ids[]=1&status_ids[]=2</code> should be used in the CMS view.

The image JSON also includes the text of the most recent English <code>alt</code> and <code>long</code> as filtered by the <code>status_id</code>. If an approved description is available, it will be supplied instead of any ready to review descriptions when <code>status_id[]=1&status_id[]=2</code> is requested.

Ex:

  {
    "id": 1,
    "canonical_id": "55917aaa613430007400000a",
    "alt": "A short title.",
    "long": "A long detailed description.",
    "path": "55917aaa613430007400000a.jpg?sha=72066b7eb6b6152ed511d52b099365afcd8b23e5",
    "url": "http://coyote.mcachicago.org/images/1"
    "group_id": 2,
    "website_id": 1,
    "created_at": "2015-06-29T17:04:42.000Z",
    "updated_at": "2015-07-30T16:26:30.000Z"
    "descriptions": [
      {
        "id": 1,
        "image_id": 1,
        "status_id": 2,
        "metum_id": 1,
        "locale": "en",
        "text": "A short title.",
        "user_id": 1,
        "created_at": "2015-07-28T14:54:58.000Z",
        "updated_at": "2015-07-28T19:39:17.000Z"
      },
      {
        "id": 6,
        "image_id": 1,
        "status_id": 2,
        "metum_id": 3,
        "locale": "en",
        "text": "A long detailed description.",
        "user_id": 2,
        "created_at": "2015-07-30T16:26:30.000Z",
        "updated_at": "2015-07-30T16:26:30.000Z"
      }
    ]
  }

  EOT
  def show
    @status_ids = params[:status_ids]  if params[:status_ids]
    @status_ids ||= [2]
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  api :POST, "images", "Create an image"
  param_group :image
  def create
    @image = Image.new(image_params)
    if @image.save
      redirect_to @image, notice: 'Image was successfully created.'
    else
      render :new
    end
  end

  api :PUT, "images/:id", "Update an image"
  param_group :image
  def update
    if @image.update(image_params)
      redirect_to @image, notice: 'Image was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /images/1
  api :DELETE, "images/:id", "Delete an image"
  def destroy
    @image.destroy
    redirect_to images_url, notice: 'Image was successfully destroyed.'
  end

  def autocomplete_tags
    @tags = ActsAsTaggableOn::Tag.
      where("name LIKE ?", "#{params[:q]}%").
      order(:name)
    respond_to do |format|
      format.json { render json: @tags.map{|t| {id: t.name, name: t.name}}}
    end
  end

  def export 
    send_data Image.all.to_csv
  end

  def import
    begin
      Image.import(params[:file])
      redirect_to root_path, {notice: "Images imported."}
    rescue => e
      logger.error e.message
      redirect_to root_path, {alert: "Images failed to import. " + e.message}
    end
  end

  #returns hash of canonical_ids to titles from MCA 
  def titles
    canonical_ids = params["canonical_ids"]

    #TODO try to read each image in cache and if not available, then bulk grab
    ids_titles = Rails.cache.fetch(canonical_ids, expires_in: 1.minute) do
      require 'multi_json'
      require 'open-uri'

      ids_titles = {}

      #prep url
      url = "https://mcachicago.org/api/v1/attachment_images/?"
      canonical_ids.each do |i|
        url += "ids[]=" + i + "&"
      end

      #request
      Rails.logger.info "grabbing images json at #{url}"
      begin
        content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, read_timeout: 10}).read
        #parse
        begin
          images_received = JSON.parse(content)

          #match ids, add titles to image cache, and set titles
          canonical_ids.each do |id|
            i = images_received.find{|i| i["id"].to_s == id.to_s}
            #puts i
            if i
              title = Rails.cache.fetch([id, 'title'].hash, expires_in: 1.minute) do
                i["title"]
              end
              ids_titles[id] = title
            end
          end

        rescue Exception => e
          Rails.logger.error "JSON parsing exception"
          Rails.logger.error e
          length = 0
        end

      rescue OpenURI::HTTPError => error
        response = error.io
        Rails.logger.error response.string
        length = 0
      end
      ids_titles
    end

    render :json => ids_titles.to_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def image_params
      params.require(:image).permit(:path, :group_id, :website_id, :canonical_id, :tag_list => [])
    end

    def search_params
      params[:q]
    end
     
    def clear_search
      if params[:search_cancel]
        params.delete(:search_cancel)
        if(!search_params.nil?)
          search_params.each do |key, param|
            search_params[key] = nil
          end
        end
      end
    end

end
