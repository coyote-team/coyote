class CreateImports < ActiveRecord::Migration[6.0]
  def change
    create_table :imports do |t|
      t.belongs_to :organization
      t.belongs_to :user
      t.json :sheet_mappings
      t.integer :status, default: 0, null: false
      t.integer :successes, default: 0, null: false
      t.integer :failures, default: 0, null: false
      t.integer :new_records, default: 0, null: false
      t.integer :duplicate_records, default: 0, null: false
      t.integer :changed_records, default: 0, null: false
      t.string :error
      t.timestamps
    end
  end
end
