class CreateLicenses < ActiveRecord::Migration[5.1]
  def change
    create_table :licenses do |t|
      t.string :name, null: false, unique: true
      t.string :title, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
