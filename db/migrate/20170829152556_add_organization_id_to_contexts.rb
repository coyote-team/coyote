class AddOrganizationIdToContexts < ActiveRecord::Migration[5.1]
  def change
    add_column :contexts, :organization_id, :integer
    add_index :contexts, :organization_id

    add_foreign_key :contexts, :organizations, :on_delete => :cascade, :on_update => :cascade
    
    Context.update_all(organization_id: Organization.first.id) if Context.any? # ok since in production there's only one Organization so far
    change_column_null :contexts, :organization_id, false
  end
end
