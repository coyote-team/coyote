class RemoveIdentifierFromResources < ActiveRecord::Migration[6.0]
  def change
    remove_column :resources, :identifier
  end
end
