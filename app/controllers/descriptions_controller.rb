class DescriptionsController < ApplicationController
  before_action :set_description,    only: %i[show edit update destroy]
  before_action :set_image,          only: %i[new edit]
  before_action :collect_meta,       only: %i[new edit]
  before_action :clear_search,       only: %i[index]
  before_action :clear_search_index, only: %i[index]

  respond_to :html, :json, :js

  helper_method :users

  def_param_group :description do
    param :description, Hash do
      param :locale, String, desc: "Must be a valid ISO 639-1 locale."
      param :text, String
      param :license, String, desc: "Options include cc0-1.0, cc-by-4.0, and cc-by-sa-4.0"
      param :status_id, Integer
      param :image_id, Integer
      param :metum_id, Integer
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
  api :GET, "descriptions/:id", "Get a description"
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
  api :POST, "descriptions", "Create a description"
  param_group :description
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
  api :PUT, "descriptions/:id", "Create a description"
  param_group :description
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
  api :DELETE, "descriptions/:id", "Delete a description"
  def destroy
    authorize @description
    @description.destroy
    flash[:notice] = "Description was successfully destroyed."
    respond_with(current_organization,@description)
  end

  def bulk
    descriptions = descriptions_params[:descriptions]

    success_count = 0
    fail_count = 0
    errors = ""

    descriptions.each do |k, a|
      if Description.find(a[:id]).update(status_id: a[:status_id])
        success_count += 1
      else
        fail_count += 1
      end
    end

    if fail_count == 0 and success_count > 0
      flash[:success] = success_count.to_s + " descriptions updated."
    elsif fail_count == 0 and success_count == 0
      flash[:notice] = "No descriptions updated."
    else
      error = fail_count.to_s + " descriptions failed.  " + errors  
      if success_count > 0 
        error +=  success_count.to_s + " descriptions updated."
      end
      flash[:error]  = error
    end
    render nothing: true
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
    params.permit(:descriptions => [:id, :status_id])
  end

  def users
    current_organization.users
  end
end
