class AlterResourcesUniqueSourceURIIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :resources, [:source_uri, :organization_id]
    add_index :resources, [:source_uri, :organization_id], unique: true, where: "source_uri IS NOT NULL AND source_uri <> ''::citext AND is_deleted IS FALSE"
  end
end
