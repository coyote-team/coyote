class RemoveScavengerHuntTables < ActiveRecord::Migration[6.0]
  def change
    %i[answers clues games hints locations players survey_answers survey_questions].each do |table|
      drop_table "scavenger_hunt_#{table}"
    end
  end
end
