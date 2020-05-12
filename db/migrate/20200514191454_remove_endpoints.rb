class RemoveEndpoints < ActiveRecord::Migration[6.0]
  def change
    remove_column :representations, :endpoint_id
    drop_table :endpoints
  end
end
