class FixWebsitesTable < ActiveRecord::Migration[5.1]
  def change
    change_column_null :websites, :title, false
    change_column_null :websites, :url, false
  end
end
