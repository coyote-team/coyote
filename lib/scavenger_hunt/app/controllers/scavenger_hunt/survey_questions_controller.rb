class ScavengerHunt::SurveyQuestionsController < ScavengerHunt::ApplicationController
  def answer
    survey_question = ScavengerHunt::SurveyQuestion.find(params[:id])
    survey_question.answer(current_player, params[:answer])
  end

  def index
    @survey_questions = ScavengerHunt::SurveyQuestion.all
  end
end

