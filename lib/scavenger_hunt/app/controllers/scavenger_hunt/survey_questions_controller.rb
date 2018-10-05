class ScavengerHunt::SurveyQuestionsController < ScavengerHunt::ApplicationController
  before_action :find_location

  def answer
    params[:answers].each do |id, answer|
      survey_question = ScavengerHunt::SurveyQuestion.find(id)
      survey_question.answer(current_player, answer)
    end
    redirect_to location_leaderboard_path(@location)
  end

  def index
    @survey_questions = ScavengerHunt::SurveyQuestion.all
  end
end
