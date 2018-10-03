class AddArchivedToMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :memberships, :active, :boolean, default: true
  end
end
