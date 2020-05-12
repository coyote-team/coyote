# frozen_string_literal: true

RSpec.describe "Resource viewing" do
  include_context "as a logged-in author user"

  let!(:resource) do
    create(:resource, organization: user_organization, name: "My Organization's Resource")
  end

  let!(:cezannne_resource) do
    create(:resource, organization: user_organization, name: "Painting by Cezanne")
  end

  let!(:other_resource) do
    create(:resource, name: "Should Not See This")
  end

  it "succeeds" do
    click_first_link "Resources"

    expect(page).to have_content("My Organization's Resource")
    expect(page).not_to have_content("Should Not See This")

    fill_in "Search by caption or description", with: "cezanne"
    click_button "Search"

    expect(page).to have_content("Painting by Cezanne")
    expect(page).not_to have_content("My Organization's Resource")
  end
end
