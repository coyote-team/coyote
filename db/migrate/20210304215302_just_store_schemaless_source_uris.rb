class JustStoreSchemalessSourceUris < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :source_uri_hash, :string, index: true
    unless reverting?
      Resource.where(source_uri_hash: nil).where.not(source_uri: nil).find_each do |resource|
        resource.update_column(:source_uri_hash, Resource.source_uri_hash_for(resource.source_uri))
      end
    end
  end
end
