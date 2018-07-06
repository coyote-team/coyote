class ScavengerHunt::LocationsController < ScavengerHunt::ApplicationController
  def index
    @locations = ScavengerHunt::Location.all
  end
end
