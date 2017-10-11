class RequireUsersToHaveAuthenticationToken < ActiveRecord::Migration[5.1]
  def change
    User.all.each(&:regenerate_authentication_token)
    change_column_null(:users,:authentication_token,false)
  end
end
