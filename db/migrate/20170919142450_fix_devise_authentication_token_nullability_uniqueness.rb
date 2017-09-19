class FixDeviseAuthenticationTokenNullabilityUniqueness < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :authentication_token
    add_index :users, :authentication_token, unique: true

    User.where(authentication_token: nil) do |u|
      u.ensure_authentication_token
      u.save!
    end

    change_column_null :users, :authentication_token, from: false, to: true
  end
end
