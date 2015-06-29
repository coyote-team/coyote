class HomeController < ApplicationController
  def index
    @queue = Description.all
  end
end
