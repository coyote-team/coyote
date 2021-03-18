# frozen_string_literal: true

RSpec.describe "Representation adding and changing" do
  include_context "with a logged-in editor user"

  let(:resource) do
    create(:resource, organization: user_organization)
  end

  before do
    create(:license)
  end

  it "succeeds" do
    visit resource_path(resource, organization_id: user_organization)

    click_first_link("Describe")
    expect(page).to have_current_path(new_representation_path(organization_id: user_organization), ignore_query: true)

    new_text = attributes_for(:representation).fetch(:text)

    fill_in "Provide a visual description", with: new_text
    select "Long", from: "Metum"

    expect {
      click_button("Create Description")
    }.to change(resource.representations, :count)
      .from(0).to(1)

    representation = resource.representations.first
    expect(page).to have_current_path(representation_path(representation, organization_id: user_organization), ignore_query: true)
    # TODO: this expectation fails because of weird Capybara text matching reasons
    # expect(page).to have_content(representation.text)

    click_first_link "Edit"
    expect(page).to have_current_path(edit_representation_path(representation, organization_id: user_organization), ignore_query: true)

    # Regression test for #464 - current_resource not set when editing fails
    fill_in "Provide a visual description", with: ""

    expect {
      click_button("Update Description")
      expect(page).to have_current_path(representation_path(representation, organization_id: user_organization), ignore_query: true)
      representation.reload
    }.not_to change(representation, :text)

    fill_in "Provide a visual description", with: "XYZ123"

    expect {
      click_button("Update Description")
      expect(page).to have_current_path(representation_path(representation, organization_id: user_organization), ignore_query: true)
      representation.reload
    }.to change(representation, :text)
      .to("XYZ123")

    click_first_link "Descriptions"
    expect(page).to have_current_path(representations_path(organization_id: user_organization), ignore_query: true)
  end
end
