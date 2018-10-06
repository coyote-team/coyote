class AddTimeColumnsToScavengerHuntGames < ActiveRecord::Migration[5.2]
  def change
    change_table :scavenger_hunt_games do |t|
      t.integer :elapsed_time_in_seconds, default: 0
      t.integer :penalty_time_in_seconds, default: 0
    end
  end
end
