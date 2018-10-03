class AddDefaultFlagToResourceGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :resource_groups, :default, :boolean, default: false
  end
end
