class CreateMeta < ActiveRecord::Migration
  def change
    create_table :meta do |t|
      t.string :title
      t.text :instructions

      t.timestamps
    end
  end
end
