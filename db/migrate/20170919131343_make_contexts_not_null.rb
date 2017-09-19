class MakeContextsNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :contexts, :title, false
  end
end
