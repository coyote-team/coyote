class AddUniqueIndexToOrganizationTitle < ActiveRecord::Migration[5.1]
  def change
    add_index :organizations, :title, unique: true
  end
end
