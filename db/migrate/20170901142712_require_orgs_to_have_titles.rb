class RequireOrgsToHaveTitles < ActiveRecord::Migration[5.1]
  def change
    change_column_null :organizations, "title", false
  end
end
