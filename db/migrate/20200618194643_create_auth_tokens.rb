class CreateAuthTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :auth_tokens do |t|
      t.belongs_to :user
      t.string :token, index: true
      t.string :user_agent
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :auth_tokens, [:token, :user_id]
  end
end
