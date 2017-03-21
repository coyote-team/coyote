class AddLicenseToDescriptions < ActiveRecord::Migration
  def change
    add_column :descriptions, :license, :string, default: "cc0-1.0"
  end
end
