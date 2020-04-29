class CreateResourceWebhookCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_webhook_calls do |t|
      t.belongs_to :resource, null: false
      t.string :uri, null: false
      t.json :body
      t.integer :response
      t.text :error
      t.timestamps
    end
  end
end
