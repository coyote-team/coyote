class RemoveUserRole < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :role
    
    execute <<~SQL
    DROP TYPE user_role
    SQL
  end
end
