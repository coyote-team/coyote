class AddResourceGroupRegexField < ActiveRecord::Migration[6.0]
  def change
    add_column :resource_groups, :auto_match_host_uris, :string, array: true, default: [], index: true, null: false
  end
end
