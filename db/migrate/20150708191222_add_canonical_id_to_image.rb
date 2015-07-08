class AddCanonicalIdToImage < ActiveRecord::Migration
  def change
    add_column :images, :canonical_id, :string
  end
end
