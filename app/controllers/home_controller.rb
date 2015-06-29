class HomeController < ApplicationController
  def index
    @queue = Description.all
    #if user
      #TODO scope to user
      #assigned
      #for review
      #completed
    #if admin
      #unassigned
  end
end
