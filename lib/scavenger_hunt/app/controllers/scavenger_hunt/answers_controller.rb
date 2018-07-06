# Make resources type-ahead-able
require "pg_search"

Resource.send :include, PgSearch
Resource.send :pg_search_scope, :typeahead, against: :title, using: {
  tsearch: {
    normalization: 4,
    prefix: true
  }
}

class ScavengerHunt::AnswersController < ScavengerHunt::ApplicationController

  TYPEAHEAD_LIMIT = 10

  before_action :find_game
  before_action :find_clue

  def correct
  end

  def create
    @answer = @clue.answers.create!(answer_params)
    if @answer.valid? && @answer.is_correct?
      if @game.finished?
        redirect_to finished_game_path
      else
        redirect_to correct_game_clue_answer_path
      end
    else
      redirect_to incorrect_game_clue_answer_path
    end
  end

  def new
    @answer = @clue.answers.new
  end
  alias incorrect new

  def typeahead
    render json: Resource.limit(TYPEAHEAD_LIMIT).typeahead(params[:q]).as_json(only: %w(id title))
  end

  private

  def answer_params
    params.require(:answer).permit(:resource_id)
  end
end
