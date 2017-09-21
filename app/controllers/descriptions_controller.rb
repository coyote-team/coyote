class DescriptionsController < ApplicationController
  before_action :set_description,    only: %i[show edit update destroy]
  before_action :set_image,          only: %i[new edit]
  before_action :collect_meta,       only: %i[new edit]
  before_action :clear_search,       only: %i[index]
  before_action :clear_search_index, only: %i[index]

  helper_method :users

  respond_to :html
  
  # GET /descriptions
  def index
    authorize Description

    if request.format.html? && current_user
      @search_cache_key = search_params

      if search_params
        search_params["text_cont_all"] = search_params["text_cont_all"].split(" ") if search_params["text_cont_all"]
      end

      @q = current_organization.descriptions.ordered.ransack(search_params)

      @descriptions = @q.result(distinct: true).page(params[:page]) 
    else
      @descriptions = current_organization.descriptions.ordered.page(params[:page])
    end
  end

  # GET /descriptions/1
  def show
    authorize @description
  end

  # GET /descriptions/new
  def new
    authorize Description
    @description = Description.new

    if params[:user_id] 
      @author = User.find(params[:user_id])
    else
      @author = current_user
    end

    if @image
      @description.image = @image
      @siblings = @description.image.descriptions
    end
  end

  # GET /descriptions/1/edit
  def edit
    authorize @description
    @siblings = @description.image.descriptions
  end

  # POST /descriptions
  def create
    authorize Description

    @description = Description.new(description_params)
    @description.user = current_user

    if @description.save
      flash[:notice] = "#{@description} was successfully created."
    else
      flash[:error] = "We were unable to complete the description, please see errors below."
      logger.warn "Unable to create Description: #{@description.error_sentence}"
    end

    respond_with(current_organization,@description)
  end

  # PATCH/PUT /descriptions/1
  def update
    authorize @description

    if @description.update(description_params)
      flash[:notice] = "#{@description} was successfully updated."
      redirect_to [current_organization,@description]
    else
      logger.warn "Unable to update #{@description}: #{@description.error_sentence}"
      render :edit
    end
  end

  # DELETE /descriptions/1
  def destroy
    authorize @description
    @description.destroy
    flash[:notice] = "Description was successfully destroyed."
    respond_with(current_organization,@description)
  end

  private

  def set_description
    @description = current_organization.descriptions.find(params[:id])
  end

  def set_image
    if params[:image_id]
      @image = current_organization.images.find(params[:image_id])
    else
      @image = @description.image if @description
    end
  end

  def description_params
    params.require(:description).permit(:image_id,:status_id,:metum_id,:locale,:text,:license,:user_id)
  end

  def collect_meta
    @meta = Metum.all
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

  def descriptions_params
    params.permit(descriptions: %i[id status_id])
  end

  def users
    current_organization.users
  end
end
