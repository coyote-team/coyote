class FixMetaTable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :meta, :title, false
    change_column_default :meta, :instructions, from: nil, to: ''
    change_column_null :meta, :instructions, false

    add_reference :meta, :organization, null: true, :on_delete => :cascade, :on_update => :cascade
  end
end
