class AddIsDeletedFlagToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :is_deleted, :boolean, default: false
    add_index :organizations, :is_deleted
  end
end
