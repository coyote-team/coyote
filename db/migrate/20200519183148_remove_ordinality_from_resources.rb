class RemoveOrdinalityFromResources < ActiveRecord::Migration[6.0]
  def change
    remove_column :resources, :ordinality
  end
end
