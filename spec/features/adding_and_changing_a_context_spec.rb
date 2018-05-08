RSpec.feature "Adding and editing a resource group" do
  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    it "succeeds" do
      click_link "Resource Groups"
      click_link "New Resource Group"
      expect(page.current_path).to eq(new_organization_resource_group_path(user_organization))

      fill_in "Title", with: "Scavenger Hunt"

      expect {
        click_button 'Create Resource Group'
      }.to change(ResourceGroup, :count).from(0).to(1)

      resource_group = ResourceGroup.first
      expect(page.current_path).to eq(organization_resource_group_path(user_organization, resource_group))

      click_link "Edit"
      fill_in "Title", with: "Treasure Hunt"

      expect {
        click_button 'Update Resource Group'
        resource_group.reload
      }.to change(resource_group, :title).to("Treasure Hunt")

      expect(page.current_path).to eq(organization_resource_group_path(user_organization, resource_group))
    end
  end
end
