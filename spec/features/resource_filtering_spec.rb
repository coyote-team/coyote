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

  let!(:deleted_resource) do
    create(:resource, is_deleted: true, organization: user_organization, name: "Cezanne was deleted")
  end

  it "succeeds" do
    click_first_link "Resources"

    expect(page).to have_content(resource.name)
    expect(page).not_to have_content(other_resource.name)
    expect(page).not_to have_content(deleted_resource.name)

    fill_in "Search by caption or description", with: "cezanne"
    click_button "Search"

    expect(page).to have_content(cezannne_resource.name)
    expect(page).not_to have_content(resource.name)
    expect(page).not_to have_content(deleted_resource.name)
  end
end
