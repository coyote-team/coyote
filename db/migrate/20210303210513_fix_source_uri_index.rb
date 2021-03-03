class FixSourceURIIndex < ActiveRecord::Migration[6.0]
  def up
    # Remove the old index; we don't need it sucking up resources
    remove_index :resources, name: :index_resources_on_schemaless_source_uri

    # Add a trigram index
    enable_extension :pg_trgm
    add_index :resources, "source_uri gin_trgm_ops", name: :index_resources_on_schemaless_source_uri, using: 'gin'
  end

  def down
    # Remove the old trigram index and walk back the trigram extension
    remove_index :resources, name: :index_resources_on_schemaless_source_uri
    disable_extension :pg_trgm

    # Restore the original index (that didn't work but whatever, that's why this file exists)
    add_index :resources, "REVERSE(source_uri) text_pattern_ops", name: :index_resources_on_schemaless_source_uri
  end
end

