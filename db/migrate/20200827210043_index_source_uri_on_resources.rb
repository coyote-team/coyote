class IndexSourceURIOnResources < ActiveRecord::Migration[6.0]
  def change
    add_index :resources, :canonical_id
    add_index :resources, :source_uri
  end
end
