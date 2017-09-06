class AddRoleTypeForMemberships < ActiveRecord::Migration[5.1]
  def change
    execute <<~SQL
    CREATE TYPE membership_role AS ENUM 
    ('guest','viewer','author','editor','admin','owner')
    SQL

    add_column :memberships, :role, :Membership_role, index: true, null: false, default: 'guest'
  end
end
