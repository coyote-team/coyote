class CreateImports < ActiveRecord::Migration[6.0]
  def change
    create_table :imports do |t|
      t.belongs_to :organization
      t.belongs_to :user
      t.json :column_mapping
      t.integer :status, default: 0, null: false
      t.string :error
      t.timestamps
    end
  end
end
