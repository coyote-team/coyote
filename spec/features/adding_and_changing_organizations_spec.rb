# frozen_string_literal: true

RSpec.describe "Adding and changing an organization" do
  include_context "with a logged-in staff user"

  it "succeeds" do
    click_link "Organizations"
    expect(page).to have_current_path(organizations_path, ignore_query: true)
    click_first_link "Add Organization"
    expect(page).to have_current_path(new_organization_path, ignore_query: true)

    fill_in "Name", with: "Acme Museum"
    select "cc0-1.0", from: "Default license"

    expect {
      click_button "Create Organization"
    }.to change(user.organizations, :count).from(1).to(2)

    organization = user.organizations.find_by!(name: "Acme Museum")

    expect(user.memberships.find_by!(organization: organization).role).to eq("owner")
    expect(page).to have_current_path(organization_path(organization), ignore_query: true)
    expect(page).to have_content("Acme Museum")

    click_first_link "Assignments"
    expect(page).to have_current_path(assignments_path(organization_id: organization), ignore_query: true)
  end
end
