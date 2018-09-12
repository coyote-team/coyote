class RenameCluePromptToQuestion < ActiveRecord::Migration[5.2]
  def change
    rename_column :scavenger_hunt_clues, :prompt, :question
  end
end
