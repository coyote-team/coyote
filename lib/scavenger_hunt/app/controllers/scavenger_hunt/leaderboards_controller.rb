class ScavengerHunt::LeaderboardsController < ScavengerHunt::ApplicationController
  def show
    @players = ScavengerHunt::Player.where.not(name: nil).for_leaderboard.limit(10)
  end
end
