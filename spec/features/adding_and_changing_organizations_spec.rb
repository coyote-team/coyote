RSpec.describe "Adding and changing an organization" do
  include_context "as a logged-in viewer user"

  let(:organization_attributes) do
    attributes_for(:organization).tap(&:symbolize_keys!)
  end

  it "succeeds" do
    click_link "Organizations"
    click_first_link "New Organization"
    expect(page.current_path).to eq(new_organization_path)

    fill_in "Title", with: "Acme Museum"

    expect {
      click_button "Create Organization"
    }.to change(Organization,:count).from(0).to(1)

    organization = Organization.first
    expect(page.current_path).to eq(organization_path(organization))
    expect(page).to have_content("Acme Museum")

    click_link "Edit"
    fill_in "Title", with: "ABC Museum"

    expect {
      click_button "Update Organization"
      organization.reload
    }.to change(organization,:title).to("ABC Museum")
  end
end
