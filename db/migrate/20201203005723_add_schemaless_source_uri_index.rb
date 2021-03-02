class AddSchemalessSourceURIIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :resources, "REVERSE(source_uri) text_pattern_ops", name: :index_resources_on_schemaless_source_uri
  end
end
