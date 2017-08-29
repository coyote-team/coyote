class AlterDefaultRoleForNewUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :role, :user_role, :default => :guest
  end
end
