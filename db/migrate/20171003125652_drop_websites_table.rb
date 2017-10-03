class DropWebsitesTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :images, :website_id
    drop_table :websites
  end
end
