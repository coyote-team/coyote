class MakeDefaultResourceTypeImage < ActiveRecord::Migration[6.0]
  def change
    execute "UPDATE resources SET resource_type = 'image'"
    change_column :resources, :resource_type, :resource_type, default: "image", null: false
  end
end
