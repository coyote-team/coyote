class MoveDefaultLicenseToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :default_license_id, :integer
    execute "UPDATE organizations SET default_license_id = #{License.where(is_default: true).first_id || License.first.id}"
    change_column :organizations, :default_license_id, :integer, null: false
    remove_column :licenses, :is_default
  end
end
