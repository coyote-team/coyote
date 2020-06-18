class RemovePasswordResetToken < ActiveRecord::Migration[6.0]
  def change
    %i[remember_created_at reset_password_token reset_password_sent_at unlock_token].each do |column|
      remove_column :users, column
    end
  end
end
