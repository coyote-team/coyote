class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_action :clear_search, only: [:index]
  before_filter :users, only: [:create, :edit, :update, :destroy]

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
  api :GET, "images", "Get an index of images"
  param :canonical_id,  String , required: false
  description  <<-EOT
    If the result is multiple images, this endpoints returns an index object with <code>_metadata</code> and <code>results</code>.
    If the result is a single image queried by <code>canonical_id</code>, an object is returned in the style of <code>GET</code> <code>/images/1</code>.

  EOT
  def index
    if params[:canonical_id].present? 
      @image = Image.find_by(canonical_id: params[:canonical_id])
    else
      @q = Image.ransack(search_params)

      if params[:tag].present? 
        @images = Image.tagged_with(params[:tag]).page(params[:page]) 
      else
        @images = @q.result(distinct: true).page(params[:page]) 
      end

      #TODO cache
      @tags = Image.tag_counts_on(:tags)
    end

  end

  # GET /images/1
  api :GET, "images/:id", "Get an image"
  description  <<-EOT
Includes approved descriptions in a hash.

Also includes the text of the most recent approved English <code>alt</code>,  <code>caption</code>, and <code>long</code>.

Ex:

  {
    "id": 1,
    "canonical_id": "55917aaa613430007400000a",
    "alt": "A short title.",
    "caption": "A caption that clarifies.",
    "long": "A long detailed description.",
    "path": "55917aaa613430007400000a.jpg?sha=72066b7eb6b6152ed511d52b099365afcd8b23e5",
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
        "id": 5,
        "image_id": 1,
        "status_id": 2,
        "metum_id": 2,
        "locale": "en",
        "text": "A caption that clarifies.",
        "user_id": 2,
        "created_at": "2015-07-29T16:26:30.000Z",
        "updated_at": "2015-07-29T16:26:30.000Z"
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def image_params
      params.require(:image).permit(:path, :group_id, :website_id, :tag_list, :canonical_id)
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
