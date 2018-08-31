class ScavengerHunt::AnswersController < ScavengerHunt::ApplicationController
  before_action :find_game
  before_action :find_clue

  def correct
  end

  def create
    @answer = @clue.answers.create!(answer: answer_param)

    if @answer.valid? && @answer.is_correct?
      if @game.finished?
        redirect_to finished_game_path(@game)
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

  private

  def answer_param
    params.require(:answer)
  end
end
