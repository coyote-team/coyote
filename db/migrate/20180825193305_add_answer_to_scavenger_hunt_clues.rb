class AddAnswerToScavengerHuntClues < ActiveRecord::Migration[5.2]
  def change
    add_column :scavenger_hunt_clues, :answer, :text
    add_column :scavenger_hunt_answers, :answer, :text
    remove_column :scavenger_hunt_answers, :resource_id
  end
end
