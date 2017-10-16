class AddIndexToResourcesPriority < ActiveRecord::Migration[5.1]
  def change
    add_index :resources, :priority
  end
end
