class FixAssignmentsIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :assignments, :user_id
    remove_index :assignments, :image_id

    add_index :assignments, %i[user_id image_id], unique: true
  end
end
