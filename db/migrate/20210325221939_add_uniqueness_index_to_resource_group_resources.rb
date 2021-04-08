class AddUniquenessIndexToResourceGroupResources < ActiveRecord::Migration[6.0]
  def change
    remove_index :resource_group_resources, [:resource_id, :resource_group_id]
    add_index :resource_group_resources, [:resource_id, :resource_group_id], name: "index_resources_resource_group_join", unique: true
  end
end
