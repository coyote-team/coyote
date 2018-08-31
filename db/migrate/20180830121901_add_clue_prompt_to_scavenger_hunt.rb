class AddCluePromptToScavengerHunt < ActiveRecord::Migration[5.2]
  def change
    add_column :scavenger_hunt_clues, :prompt, :string, default: "I think it is..."
  end
end
