class ChangeDefaultReosurceTitle < ActiveRecord::Migration[6.0]
  def change
    change_column :resources, :title, :string, default: Resource::DEFAULT_NAME
  end
end
