class AddOrdinalityToResources < ActiveRecord::Migration[5.2]
  def change
    add_column :resources, :ordinality, :integer
  end
end
