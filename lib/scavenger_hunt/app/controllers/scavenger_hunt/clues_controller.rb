class ScavengerHunt::CluesController < ScavengerHunt::ApplicationController

  before_action :find_game
  before_action :find_clue, only: %w(show)

  def index
  end

  def show
    redirect_to(correct_game_clue_answer_path(@game, @clue)) if @clue.answered?
  end
end
