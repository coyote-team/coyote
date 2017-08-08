class AddOrganizationToImages < ActiveRecord::Migration[5.1]
  def change
    add_reference :images, :organization, foreign_key: { :on_delete => :restrict, :on_update => :cascade }
  end
end
