class MakeEndpointNameUnique < ActiveRecord::Migration[5.1]
  def change
    add_index :endpoints, :name, unique: true
  end
end
