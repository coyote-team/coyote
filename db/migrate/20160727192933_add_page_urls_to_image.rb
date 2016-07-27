class AddPageUrlsToImage < ActiveRecord::Migration
  def change
    add_column :images, :page_urls, :text
  end
end
