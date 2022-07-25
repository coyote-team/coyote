class AlterOrganizationsUniqueNameIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :organizations, :name
    add_index :organizations, :name, unique: true, where: "is_deleted IS FALSE"
  end
end
