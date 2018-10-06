class ScavengerHunt::SurveyQuestion < ScavengerHunt::ApplicationRecord
  before_create :set_position

  def answer(player, answer)
    return unless player
    player.survey_answers.find_or_initialize_by(survey_question_id: id).update_attributes!(answer: answer)
  end
end
