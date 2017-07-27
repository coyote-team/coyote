class MetaController < ApplicationController
  before_filter :check_authorization, only: [:create, :edit, :update, :destroy]
  before_action :set_metum, only: [:show, :edit, :update, :destroy]

  # GET /meta
  api :GET, "meta", "Get an index of meta"
  def index
    @meta = Metum.all
  end

  # GET /meta/1
  api :GET, "meta/:id", "Get a metum"
  def show
  end

  # GET /meta/new
  def new
    @metum = Metum.new
  end

  # GET /meta/1/edit
  def edit
  end

  # POST /meta
  def create
    @metum = Metum.new(metum_params)

    if @metum.save
      redirect_to @metum, notice: 'Metum was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /meta/1
  def update
    if @metum.update(metum_params)
      redirect_to @metum, notice: 'Metum was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /meta/1
  #def destroy
  #@metum.destroy
  #redirect_to meta_url, notice: 'Metum was successfully destroyed.'
  #end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_metum
    @metum = Metum.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def metum_params
    params.require(:metum).permit(:title, :instructions)
  end
end
