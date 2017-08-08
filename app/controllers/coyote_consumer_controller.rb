class CoyoteConsumerController < ApplicationController
  layout :false

  def iframe
    redirect_to ActionController::Base.helpers.asset_path("coyote_consumer.js")
  end
end
