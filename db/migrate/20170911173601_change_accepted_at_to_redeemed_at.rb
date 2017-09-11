class ChangeAcceptedAtToRedeemedAt < ActiveRecord::Migration[5.1]
  def change
    rename_column :invitations, :accepted_at, :redeemed_at
  end
end
