class AddIndexToResourceLinks < ActiveRecord::Migration[5.1]
  def change
    add_index :resource_links, %i[subject_resource_id verb object_resource_id], unique: true, name: 'index_resource_links'
  end
end
