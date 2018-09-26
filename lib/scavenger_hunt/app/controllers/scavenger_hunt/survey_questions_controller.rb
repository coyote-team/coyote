class ScavengerHunt::SurveyQuestionsController < ScavengerHunt::ApplicationController
  def answer
    params[:answers].each do |id, answer|
      survey_question = ScavengerHunt::SurveyQuestion.find(id)
      survey_question.answer(current_player, answer)
    end
  end

  def index
    @survey_questions = ScavengerHunt::SurveyQuestion.all
  end
end
