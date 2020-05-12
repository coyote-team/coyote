# frozen_string_literal: true

RSpec.describe "Adding and editing a resource group" do
  describe "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    it "succeeds" do
      click_link "Resource Groups"
      click_link "New Resource Group"
      expect(page).to have_current_path(new_organization_resource_group_path(user_organization), ignore_query: true)

      fill_in "Name", with: "Scavenger Hunt"

      expect {
        click_button "Create Resource Group"
      }.to change(ResourceGroup, :count).from(1).to(2)

      resource_group = ResourceGroup.last
      expect(page).to have_current_path(organization_resource_group_path(user_organization, resource_group), ignore_query: true)

      click_link "Edit"
      fill_in "Name", with: "Treasure Hunt"

      expect {
        click_button "Update Resource Group"
        resource_group.reload
      }.to change(resource_group, :name).to("Treasure Hunt")

      expect(page).to have_current_path(organization_resource_group_path(user_organization, resource_group), ignore_query: true)
    end
  end
end
