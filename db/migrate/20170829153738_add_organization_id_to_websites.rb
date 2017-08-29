class AddOrganizationIdToWebsites < ActiveRecord::Migration[5.1]
  def change
    add_column :websites, :organization_id, :integer
    add_index :websites, :organization_id

    add_foreign_key :websites, :organizations, :on_delete => :cascade, :on_update => :cascade
    
    Website.update_all(organization_id: Organization.first.id) if Website.any? # ok since in production there's only one Organization so far
    change_column_null :websites, :organization_id, false
  end
end
