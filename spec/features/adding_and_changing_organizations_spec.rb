RSpec.describe "Adding and changing an organization" do
  include_context "as a logged-in viewer user"

  let(:organization_attributes) do
    attributes_for(:organization).tap(&:symbolize_keys!)
  end

  it "succeeds" do
    click_link "Organizations"
    expect(current_path).to eq(organizations_path)
    click_first_link "New Organization"
    expect(page.current_path).to eq(new_organization_path)

    fill_in "Title", with: "Acme Museum"

    expect {
      click_button "Create Organization"
    }.to change(Organization,:count).from(1).to(2)

    organization = user.organizations.find_by!(title: "Acme Museum")
    expect(page.current_path).to eq(organization_path(organization))
    expect(page).to have_content("Acme Museum")
  end
end
