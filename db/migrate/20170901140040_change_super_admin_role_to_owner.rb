class ChangeSuperAdminRoleToOwner < ActiveRecord::Migration[5.1]
  def up
    remove_column :users, :role
    
    execute <<~SQL
    DROP TYPE user_role
    SQL

    execute <<~SQL
    CREATE TYPE user_role AS ENUM 
    ('guest','viewer','author','editor','admin','owner','staff')
    SQL

    add_column :users, :role, :user_role, index: true, null: false, default: 'guest'
  end
end
