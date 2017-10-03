class CreateResourceLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :resource_links do |t|
      t.references :subject_resource, foreign_key: { :to_table => :resources, :on_delete => :cascade, :on_update => :cascade }, null: false
      t.string :verb, null: false
      t.references :object_resource, foreign_key: { :to_table => :resources, :on_delete => :cascade, :on_update => :cascade }, null: false

      t.timestamps
    end
  end
end
