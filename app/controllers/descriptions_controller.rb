class DescriptionsController < ApplicationController
  before_action :set_description, only: [:show, :edit, :update, :destroy]
  before_action :set_image, only: [:new, :edit]
  before_action :collect_meta, only: [:new, :edit]
  before_action :set_author, only: [:new]

  respond_to :html, :json

  # GET /descriptions
  def index
    @descriptions = Description.all
  end

  # GET /descriptions/1
  def show
  end

  # GET /descriptions/new
  def new
    @description = Description.new
  end

  # GET /descriptions/1/edit
  def edit
  end

  # POST /descriptions
  def create
    @description = Description.new(description_params)
    flash[:notice] = "#{@description} was successfully created." if @description.save
    respond_with(@description)
  end

  # PATCH/PUT /descriptions/1
  def update
    flash[:notice] = "#{@description} was successfully updated." if @description.update(description_params)
    respond_with @description
  end

  # DELETE /descriptions/1
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
      @author = User.find(params[:user_id]) if params[:user_id]
    end

    def set_image
      if params[:image_id]
        @image = Image.find(params[:image_id]) 
      else
        @image = @description.image
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
