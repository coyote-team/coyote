class ChangePageUrlsToPgArrayNewWay < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :new_page_urls, :text, array:true, default: [], null: false

    Image.where("page_urls != '{}'").find_each do |image|
      urls = JSON(image.page_urls)
      image.new_page_urls = urls
      image.save!
    end

    rename_column :images, :page_urls, :old_page_urls
    rename_column :images, :new_page_urls, :page_urls
    
    # we'll keep old_page_urls for now, can eventually delete
  end
end
