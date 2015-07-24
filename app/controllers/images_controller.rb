class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_filter :users, only: [:create, :edit, :update, :destroy]

  respond_to :html, :json

  def_param_group :image do
    param :image, Hash do
      param :canonical_id,  String #(255)
      param :path,           String #(255)
      param :website_id,    :number
      param :group_id,      :number
      param :created_at,    DateTime
      param :updated_at,    DateTime
    end
  end

  # GET /images
  api :GET, "images", "Get an index of images"
  def index
    @q = Image.ransack(params[:q])

    if params[:tag].present? 
      @images = Image.tagged_with(params[:tag]).page(params[:page]) 
    else
      @images = @q.result(distinct: true).page(params[:page]) 
    end


    @tags = Image.tag_counts_on(:tags)
  end

  # GET /images/1
  api :GET, "images/:id", "Get an image"
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

end
