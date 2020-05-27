class AddIsRequiredToMeta < ActiveRecord::Migration[6.0]
  def change
    add_column :meta, :is_required, :boolean, default: false, null: false
    execute "UPDATE meta SET is_required = TRUE"
  end
end
