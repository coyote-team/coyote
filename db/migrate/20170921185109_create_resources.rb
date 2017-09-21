class CreateResources < ActiveRecord::Migration[5.1]
  def up
    # see http://dublincore.org/documents/dcmi-terms/#dcmitype-Collection
    execute <<-SQL
    CREATE TYPE resource_type AS ENUM 
    ('collection','dataset','event','image','interactive_resource','moving_image','physical_object','service','software','sound','still_image','text')
    SQL
    
    create_table :resources do |t| 
      t.string :identifier, null: false
      t.string :title, null: false, default: 'Unknown'
      t.column :resource_type, :resource_type, null: false
      t.string :canonical_id, null: false
      t.string :source_uri
      t.references :context, foreign_key: { :on_delete => :restrict, :on_update => :cascade }, null: false, index: true
      t.references :organization, foreign_key: { :on_delete => :restrict, :on_update => :cascade }, null: false, index: true

      t.timestamps
    end

    add_index :resources, %i[organization_id canonical_id], unique: true
    add_index :resources, :identifier, unique: true
  end

  def down
    drop_table :resources
    execute 'DROP TYPE resource_type'
  end
end
