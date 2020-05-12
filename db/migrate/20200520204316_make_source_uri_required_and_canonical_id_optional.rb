class MakeSourceUriRequiredAndCanonicalIdOptional < ActiveRecord::Migration[6.0]
  def change
    change_column :resources, :source_uri, :citext, null: false
    change_column :resources, :canonical_id, :citext, null: true
  end
end
