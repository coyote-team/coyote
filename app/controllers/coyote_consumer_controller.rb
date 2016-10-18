class CoyoteConsumerController < ApplicationController
  protect_from_forgery except: :index

  layout :false

  def index
  end
end
