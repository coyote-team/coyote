class ScavengerHunt::LocationsController < ScavengerHunt::ApplicationController
  def end_all
  end

  def index
    @locations = ScavengerHunt::Location.all
  end

  private

  helper_method def any_locations_played?
    @locations.any? {|location| location.played?(current_player) }
  end
end
