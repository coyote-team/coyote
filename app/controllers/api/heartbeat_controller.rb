# frozen_string_literal: true

class Api::HeartbeatController < Api::ApplicationController
  skip_before_action :require_api_authentication

  def show
    render json: {status: "okay"}, status: :ok
  end
end
