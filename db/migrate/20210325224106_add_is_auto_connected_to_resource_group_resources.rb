class AddIsAutoConnectedToResourceGroupResources < ActiveRecord::Migration[6.0]
  def change
    add_column :resource_group_resources, :is_auto_matched, :boolean, default: false, null: false
  end
end
