class ScavengerHunt::LeaderboardsController < ScavengerHunt::ApplicationController

  before_action :find_location

  def show
    @players = @location.players.where.not(name: nil).limit(10)
  end

end

