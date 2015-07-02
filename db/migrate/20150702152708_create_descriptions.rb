class CreateDescriptions < ActiveRecord::Migration
  def change
    create_table :descriptions do |t|
      t.string :locale, default: "en"
      t.text :text
      t.references :status, index: true, foreign_key: true
      t.references :image, index: true, foreign_key: true
      t.references :metum, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
