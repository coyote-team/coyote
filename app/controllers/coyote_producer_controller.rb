class CoyoteProducerController < ApplicationController

  layout 'coyote_producer'

  def index
  end

  def buffer
    render :text => "", :layout => "coyote_producer_buffer"
  end

end
