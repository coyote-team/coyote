class AddIsDeletedIndicesToResources < ActiveRecord::Migration[6.0]
  def change
    add_index :resources, :is_deleted
  end
end
