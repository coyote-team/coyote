class RestrictImageOrganizationForeignKey < ActiveRecord::Migration[5.1]
  def change
    organization = Organization.find_or_create_by!(title: "MCA Chicago")
    Image.update_all(organization_id: organization.id)
    change_column_null(:images,:organization_id,false)
  end
end
