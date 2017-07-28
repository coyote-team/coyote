class AddRolesEnumeratedType < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE TYPE user_role AS ENUM 
    ('viewer','author','editor','admin','super_admin','staff')
    SQL

    add_column :users, :role, :user_role, index: true, null: false, default: 'viewer'
  end

  def down
    remove_column :users, :role

    execute <<-SQL
      DROP TYPE user_role;
    SQL
  end
end
