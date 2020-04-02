class CleanUpSourceUriTypes < ActiveRecord::Migration[6.0]
  def change
    enable_extension :citext
    change_column :resources, :source_uri, :citext
  end
end
