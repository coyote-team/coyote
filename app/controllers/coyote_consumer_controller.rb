# frozen_string_literal: true

class CoyoteConsumerController < ApplicationController
  def iframe
    redirect_to ActionController::Base.helpers.asset_path("coyote_consumer.js")
  end
end
