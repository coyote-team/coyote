# frozen_string_literal: true

RSpec.describe "Representation filtering" do
  include_context "with a logged-in author user"

  let!(:representation) do
    create(:representation, :not_approved, organization: user_organization, text: "My Organization's Description")
  end

  let!(:representation_search_target) do
    create(:representation, :approved, organization: user_organization, text: "A woman smiling")
  end

  let!(:representation_of_deleted_resource) do
    create(:representation, :approved, organization: user_organization, resource: create(:resource, organization: user_organization, is_deleted: true), text: "Deleted resource")
  end

  let!(:other_representation) do
    create(:representation, text: "Should Not See This")
  end

  it "succeeds" do
    click_first_link "Descriptions"

    expect(page).to have_content(representation.text)
    expect(page).not_to have_content(other_representation.text)
    expect(page).not_to have_content(representation_of_deleted_resource.text)

    fill_in "q[text_or_resource_canonical_id_or_resource_name_cont_all]", with: "smiling"
    click_button "Apply Filters"

    expect(page).to have_content(representation_search_target.text)
    expect(page).not_to have_content(representation.text)
    expect(page).not_to have_content(representation_of_deleted_resource.text)

    fill_in "q[text_or_resource_canonical_id_or_resource_name_cont_all]", with: ""
    check "Not Approved"
    click_button "Apply Filters"

    expect(page).not_to have_content(representation_search_target.text)
    expect(page).to have_content(representation.text)
    expect(page).not_to have_content(representation_of_deleted_resource.text)
  end
end
