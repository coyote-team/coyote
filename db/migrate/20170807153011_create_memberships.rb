class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: { :on_delete => :cascade }, index: false
      t.references :organization, null: false, foreign_key: { :on_delete => :cascade }, index: false
      t.timestamps
    end

    add_index :memberships, %i[user_id organization_id], unique: true
  end
end
