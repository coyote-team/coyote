class AddOrdinalityToRepresentations < ActiveRecord::Migration[5.2]
  def change
    add_column :representations, :ordinality, :integer
  end
end
