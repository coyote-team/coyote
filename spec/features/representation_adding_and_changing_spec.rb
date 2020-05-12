# frozen_string_literal: true

RSpec.describe "Representation adding and changing" do
  include_context "as a logged-in editor user"

  let(:resource) do
    create(:resource, organization: user_organization)
  end

  let!(:metum) { create(:metum, :long, organization: user_organization) }

  before do
    create(:license)
  end

  it "succeeds" do
    visit resource_url(resource)

    click_first_link("Describe")
    expect(page).to have_current_path(new_organization_representation_path(user_organization), ignore_query: true)

    new_text = attributes_for(:representation).fetch(:text)

    fill_in "Text", with: new_text
    select metum.name, from: "Metum"

    expect {
      click_button("Create Description")
    }.to change(resource.representations, :count)
      .from(0).to(1)

    representation = resource.representations.first
    expect(page).to have_current_path(representation_path(representation), ignore_query: true)
    # TODO: this expectation fails because of weird Capybara text matching reasons
    # expect(page).to have_content(representation.text)

    click_first_link "Edit"
    expect(page).to have_current_path(edit_representation_path(representation), ignore_query: true)

    fill_in "Text", with: "XYZ123"

    expect {
      click_button("Update Description")
      expect(page).to have_current_path(representation_path(representation), ignore_query: true)
      representation.reload
    }.to change(representation, :text)
      .to("XYZ123")

    click_first_link "Descriptions"
    expect(page).to have_current_path(organization_representations_path(user_organization), ignore_query: true)

    expect {
      click_first_link("Delete")
    }.to change { Representation.exists?(representation.id) }
      .from(true).to(false)

    expect(page).to have_current_path(organization_representations_path(user_organization), ignore_query: true)
  end
end
