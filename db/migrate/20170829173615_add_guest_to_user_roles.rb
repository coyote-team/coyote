class AddGuestToUserRoles < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!  # can't run ALTER TYPE inside a transaction, unlike most migrations
  
  def up
    execute <<~SQL
    ALTER TYPE user_role ADD VALUE 'guest' BEFORE 'viewer';
    SQL
  end
end
