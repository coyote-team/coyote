class AddIsArchivedFlagToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :scavenger_hunt_games, :is_archived, :boolean, default: false
  end
end
