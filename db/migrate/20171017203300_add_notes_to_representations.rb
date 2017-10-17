class AddNotesToRepresentations < ActiveRecord::Migration[5.1]
  def change
    add_column :representations, :notes, :text
  end
end
