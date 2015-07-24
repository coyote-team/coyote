class AddAssignmentsCountToImages < ActiveRecord::Migration
  def change
    add_column :images, :assignments_count, :integer, default: 0
  end
end
