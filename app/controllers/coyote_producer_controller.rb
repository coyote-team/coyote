class CoyoteProducerController < ApplicationController
  before_filter :allow_iframe_requests

  layout 'coyote_producer'

  def index
  end


  protected
  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end
end
