class ScavengerHunt::LeaderboardController < ScavengerHunt::ApplicationController

  def index
    @players = ScavengerHunt::Player.limit(10)
  end

end

