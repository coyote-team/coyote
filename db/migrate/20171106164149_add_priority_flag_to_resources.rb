class AddPriorityFlagToResources < ActiveRecord::Migration[5.1]
  def change
    add_column :resources, :priority_flag, :boolean, null: false, default: false
    add_index :resources, :priority_flag, order: { :priority_flag => :desc }
  end
end
