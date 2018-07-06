class ScavengerHunt::CluesController < ScavengerHunt::ApplicationController

  before_action :find_game
  before_action :find_clue, only: %w(show)

  def index
  end

  def show
  end
end
