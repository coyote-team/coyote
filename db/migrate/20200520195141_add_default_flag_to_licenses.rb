class AddDefaultFlagToLicenses < ActiveRecord::Migration[6.0]
  def change
    add_column :licenses, :is_default, :boolean, default: false
    execute "UPDATE licenses SET is_default = TRUE WHERE licenses.name = 'cc0-1.0'"
  end
end
