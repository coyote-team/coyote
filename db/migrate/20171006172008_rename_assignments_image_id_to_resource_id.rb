class RenameAssignmentsImageIdToResourceId < ActiveRecord::Migration[5.1]
  def change
    remove_column :assignments, :image_id
    add_column :assignments, :resource_id, :integer, null: false

    add_foreign_key :assignments, :resources, :on_delete => :cascade, :on_update => :cascade
    add_index :assignments, %w[resource_id user_id], unique: true
  end
end
