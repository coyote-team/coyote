class AddPriorityToResources < ActiveRecord::Migration[5.1]
  def change
    add_column :resources, :priority, :boolean, null: false, default: false
  end
end
