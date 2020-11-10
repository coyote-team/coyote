class AddFooterTextToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :footer, :string
  end
end
