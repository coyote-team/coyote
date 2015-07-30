class DescriptionsController < ApplicationController
  before_action :set_description, only: [:show, :edit, :update, :destroy]
  before_action :set_image, only: [:new, :edit]
  before_action :collect_meta, only: [:new, :edit]
  before_action :set_author, only: [:new]
  before_filter :users

  respond_to :html, :json

  def_param_group :description do
    param :description, Hash do
      param :locale, String, desc: "Must be a valid ISO 639-1 locale."
      param :text, String
      param :status_id, :number
      param :image_id, :number
      param :metum_id, :number
      param :created_at,    DateTime
      param :updated_at,    DateTime
    end
  end


  # GET /descriptions
  api :GET, "descriptions", "Get an index of descriptions"
  param :page, :number
  description  <<-EOT
  Returns an object with <code>_metadata</code> and <code>results</code>
  EOT

  def index
    @descriptions = Description.all.page params[:page]
  end

  # GET /descriptions/1
  api :GET, "descriptions/:id", "Get a description"
  def show
  end

  # GET /descriptions/new
  def new
    @description = Description.new
    @description.image_id = params[:image_id] if params[:image_id] #for populating sibling descriptions
  end

  # GET /descriptions/1/edit
  def edit
  end

  # POST /descriptions
  api :POST, "descriptions", "Create a description"
  param_group :description
  def create
    @description = Description.new(description_params)
    flash[:notice] = "#{@description} was successfully created." if @description.save
    respond_with(@description)
  end

  # PATCH/PUT /descriptions/1
  api :PUT, "descriptions/:id", "Create a description"
  param_group :description
  def update
    flash[:notice] = "#{@description} was successfully updated." if @description.update(description_params)
    respond_with @description
  end

  # DELETE /descriptions/1
  api :DELETE, "descriptions/:id", "Delete a description"
  def destroy
    @description.destroy
    flash[:notice] = "Description was successfully destroyed."
    respond_with(@description)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_description
      @description = Description.find(params[:id])
    end

    def set_author
      if params[:user_id]
        @author = User.find(params[:user_id]) 
      elsif current_user and !current_user.admin?
        @author = current_user 
      end
    end

    def set_image
      if params[:image_id]
        @image = Image.find(params[:image_id]) 
      else
        @image = @description.image if @description
      end
    end

    # Only allow a trusted parameter "white list" through.
    def description_params
      params.require(:description).permit(:image_id, :status_id, :metum_id, :locale, :text, :user_id)
    end

    def collect_meta
      @meta = Metum.all
    end
end
