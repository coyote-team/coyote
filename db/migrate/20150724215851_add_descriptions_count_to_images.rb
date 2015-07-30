class AddDescriptionsCountToImages < ActiveRecord::Migration
  def change
    add_column :images, :descriptions_count, :integer, default: 0
  end
end
