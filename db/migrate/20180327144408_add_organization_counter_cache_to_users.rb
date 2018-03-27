class AddOrganizationCounterCacheToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :organizations_count, :integer, default: 0
    User.in_batches.each_record do |user|
      user.update_attribute(:organizations_count, user.organizations.count)
    end
  end

  def down
    remove_column :users, :organizations_count
  end
end
