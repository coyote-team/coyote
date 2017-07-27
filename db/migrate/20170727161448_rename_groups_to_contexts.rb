class RenameGroupsToContexts < ActiveRecord::Migration
  def change
    rename_table :groups, :contexts
  end
end
