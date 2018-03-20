RSpec.describe "Adding and changing an organization" do
  include_context "as a logged-in staff user"

  it "succeeds" do
    click_link "Organizations"
    expect(current_path).to eq(organizations_path)
    click_first_link "New Organization"
    expect(page.current_path).to eq(new_organization_path)

    fill_in "Title", with: "Acme Museum"

    expect {
      click_button "Create Organization"
    }.to change(user.organizations, :count).from(1).to(2)

    organization = user.organizations.find_by!(title: "Acme Museum")

    expect(user.memberships.find_by!(organization: organization).role).to eq('owner')
    expect(page.current_path).to eq(organization_path(organization))
    expect(page).to have_content("Acme Museum")

    click_first_link 'Assignments'
    expect(page.current_path).to eq(organization_assignments_path(organization))
  end
end
