class JustStoreSchemalessSourceUris < ActiveRecord::Migration[6.0]
  def change
    add_column :resources, :source_uri_hash, :string, index: true
    unless reverting?
      Resource.find_each do |resource|
        resource.send(:set_source_uri_hash)
        resource.save
      end
    end
  end
end
