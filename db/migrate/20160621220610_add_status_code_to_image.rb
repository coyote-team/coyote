class AddStatusCodeToImage < ActiveRecord::Migration
  def change
    add_column :images, :status_code, :integer, default: 0

    Image.all.each do |i|
      puts i.id
      i.save
    end
  end
end
