class RemovePriorityFromResources < ActiveRecord::Migration[5.1]
  def change
    remove_column :resources, :priority
  end
end
