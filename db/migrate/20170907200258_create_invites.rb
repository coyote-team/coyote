class CreateInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :invitations do |t|
      t.string :recipient_email, null: false
      t.string :token, null: false, unique: true

      t.references :sender_user, foreign_key: { :to_table => :users, :on_delete => :cascade, :on_update => :cascade }, null: false
      t.references :recipient_user, foreign_key: { :to_table => :users, :on_delete => :cascade, :on_update => :cascade }, null: false
      t.references :organization, foreign_key: { :on_delete => :cascade, :on_update => :cascade }, null: false

      t.timestamp :accepted_at

      t.timestamps

      t.index %i[recipient_email token]
    end

    add_column :invitations, :role, :membership_role, null: false, default: 'viewer'
  end
end
