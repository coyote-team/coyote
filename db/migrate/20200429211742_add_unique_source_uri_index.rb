class AddUniqueSourceUriIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :resources, [:source_uri, :organization_id], unique: true, where: "source_uri IS NOT NULL AND source_uri != ''"
  end
end
