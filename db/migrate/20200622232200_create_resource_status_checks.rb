class CreateResourceStatusChecks < ActiveRecord::Migration[6.0]
  def change
    create_table :resource_status_checks do |t|
      t.belongs_to :resource
      t.string :source_uri, null: false
      t.integer :response, null: false
      t.timestamps
    end
  end
end
