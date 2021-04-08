class AddOrganizationAuthorsCanSelfAssignFlag < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :allow_authors_to_claim_resources, :boolean, default: false, null: false
  end
end
