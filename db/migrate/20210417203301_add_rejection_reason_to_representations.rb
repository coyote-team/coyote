class AddRejectionReasonToRepresentations < ActiveRecord::Migration[6.0]
  def change
    add_column :representations, :rejection_reason, :text
  end
end
