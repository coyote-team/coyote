module Staff
  # Staff-only CRUD functions for Endpoints
  class EndpointsController < Staff::ApplicationController
    before_action :set_endpoint, only: %i[show edit update destroy]

    helper_method :endpoint, :endpoints

    def index
      self.endpoints = Endpoint.sorted
    end

    def new
      self.endpoint = Endpoint.new
    end

    def show
    end

    def edit
    end

    def create
      self.endpoint = Endpoint.create(endpoint_params)

      if endpoint
        logger.info "Created #{endpoint}"
        redirect_to [:staff, endpoint]
      else
        logger.warn "Unable to create '#{endpoint}' due to '#{endpoint.error_sentence}'"
        render :new
      end
    end

    def update
      if endpoint.update(endpoint_params)
        redirect_to staff_endpoint_path(endpoint), notice: 'Endpoint was successfully updated'
      else
        logger.warn "Unable to update #{endpoint}: #{endpoint.error_sentence}"
        render :edit
      end
    end

    def destroy
      endpoint.destroy
      msg = "Deleted #{endpoint}"
      redirect_to staff_endpoints_path, notice: msg
    rescue ActiveRecord::DeleteRestrictionError => e
      msg = "Unable to delete '#{endpoint}' due to '#{e}'"
      logger.error msg
      redirect_to staff_endpoint_path(endpoint), alert: msg
    end

    private

    attr_accessor :endpoint, :endpoints

    def set_endpoint
      self.endpoint = Endpoint.find(params[:id])
    end

    def endpoint_params
      params.require(:endpoint).permit(:name)
    end
  end
end
