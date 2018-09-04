class RenameSurveyAnswerQuestionsId < ActiveRecord::Migration[5.2]
  def change
    rename_column :scavenger_hunt_survey_answers, :survey_questions_id, :survey_question_id
  end
end
