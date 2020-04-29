class CreateResourcesResourceGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_group_resources do |t|
      t.belongs_to :resource_group
      t.belongs_to :resource
      t.timestamps
    end

    execute "INSERT INTO resource_group_resources (resource_group_id, resource_id, created_at, updated_at) (SELECT resource_group_id, id AS resource_id, created_at, updated_at FROM resources)"

    remove_column :resources, :resource_group_id
  end
end
