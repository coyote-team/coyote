# frozen_string_literal: true

class ScavengerHunt::SurveyQuestionsController < ScavengerHunt::ApplicationController
  def answer
    params[:answers].each do |id, answer|
      survey_question = ScavengerHunt::SurveyQuestion.find(id)
      survey_question.answer(current_player, answer)
    end
    redirect_to leaderboard_path
  end

  def index
    @survey_questions = ScavengerHunt::SurveyQuestion.all
  end
end
