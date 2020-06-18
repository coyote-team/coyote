class CreatePasswordResets < ActiveRecord::Migration[6.0]
  def change
    create_table :password_resets do |t|
      t.belongs_to :user
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
  end
end
