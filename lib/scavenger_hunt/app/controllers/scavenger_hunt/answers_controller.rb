class ScavengerHunt::AnswersController < ScavengerHunt::ApplicationController
  before_action :find_game
  before_action :find_clue

  def correct
  end

  def create
    # use the similar_text gem's .similar method to score how closely the player's input and the resource's title match (integer)
    @match_score = "#{@clue.resource.title}".similar("#{params[:q]}")
    puts "this is the match score #{@match_score}"

    # setting a minimum match score of 40 allows the player some wiggle room for spelling errors
    if @match_score >= 40
      @resource = @clue.resource
    else
      @resource = nil
    end

    if @resource.present?
      @answer = @clue.answers.create!(resource_id: @resource.id)
    else
      @answer = ScavengerHunt::Answer.new
    end

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

  def answer_params
    params.require(:answer).permit(:resource_id)
  end
end
