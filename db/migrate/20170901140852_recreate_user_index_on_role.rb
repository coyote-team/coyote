class RecreateUserIndexOnRole < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :role
  end
end
