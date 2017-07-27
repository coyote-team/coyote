class StatusesController < ApplicationController
  before_filter :check_authorization, only: [:create, :edit, :update, :destroy]
  before_action :set_status, only: [:show, :edit, :update, :destroy]

  # GET /statuses
  api :GET, "statuses", "Get an index of statuses"
  def index
    @statuses = Status.all
  end

  # GET /statuses/1
  api :GET, "statuses/:id", "Get a statuses"
  def show
  end

  # GET /statuses/new
  def new
    @status = Status.new
  end

  # GET /statuses/1/edit
  def edit
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_status
    @status = Status.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def status_params
    params.require(:status).permit(:title)
  end
end
