class AddHostUrisToResources < ActiveRecord::Migration[5.1]
  def change
    # H/T https://til.hashrocket.com/posts/d243430211-default-to-empty-array-in-postgres
    execute <<~SQL
    ALTER TABLE resources
    ADD COLUMN host_uris character varying[] not null default '{}'
    SQL
  end
end
