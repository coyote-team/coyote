class RenameContextToResourceGroups < ActiveRecord::Migration[5.1]
  def change
    rename_table :contexts, :resource_groups
    rename_column :resources, :context_id, :resource_group_id
  end
end
