class CreateRepresentations < ActiveRecord::Migration[5.1]
  def change
    create_table :representations do |t|
      t.references :resource, foreign_key: { :on_delete => :restrict, :on_update => :cascade }, index: true, null: false
      t.text :text
      t.string :content_uri
      t.column :status, :representation_status, index: true, null: false, default: 'ready_to_review'
      t.references :metum, foreign_key: { :on_delete => :restrict, :on_update => :cascade }, null: false
      t.references :author, foreign_key: { :to_table => :users, :on_delete => :restrict, :on_update => :cascade }, index: true, null: false
      t.string :content_type, null: false, default: 'text/plain'
      t.string :language, null: false
      t.references :license, foreign_key: { :on_delete => :restrict, :on_update => :cascade }, null: false, index: true

      t.timestamps
    end
  end
end
