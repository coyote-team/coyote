class AddIsDeletedFlagToResources < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :is_deleted, :boolean, default: false, null: false
  end
end
