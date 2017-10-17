class AddRepresentationsCountToResources < ActiveRecord::Migration[5.1]
  def change
    add_column :resources, :representations_count, :integer, null: false, default: 0
    add_index :resources, :representations_count
    Resource.find_each { |r| Resource.reset_counters(r.id,:representations) }
  end
end
