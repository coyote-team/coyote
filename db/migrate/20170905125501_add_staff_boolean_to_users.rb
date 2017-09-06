class AddStaffBooleanToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :staff, :boolean, null: false, default: false, index: true
  end
end
