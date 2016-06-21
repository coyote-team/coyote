class AddPriorityBooleanToImages < ActiveRecord::Migration
  def change
    add_column :images, :priority, :boolean, default: false
  end
end
