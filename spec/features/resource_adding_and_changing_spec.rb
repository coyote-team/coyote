# frozen_string_literal: true

RSpec.describe "Resource adding and changing" do
  include_context "as a logged-in editor user"

  let!(:resource_group) { create(:resource_group, organization: user_organization) }

  let(:resource_attributes) do
    attributes_for(:resource, canonical_id: "abc123").symbolize_keys
  end

  it "succeeds" do
    click_first_link "Resources"
    click_first_link("New Resource")

    within(".form-field.resource_resource_groups") do
      user_organization.resource_groups.default.each do |other_group|
        uncheck(other_group.name)
      end
      check(resource_group.name)
    end

    fill_in "Caption", with: resource_attributes[:name]
    fill_in "Canonical ID", with: resource_attributes[:canonical_id]
    fill_in "Source URI", with: resource_attributes[:source_uri]
    fill_in "Host URIs", with: "http://example.com/abc\nhttp://example.com/xyz"

    select(resource_attributes[:resource_type].titleize, from: "Type")

    expect {
      click_button("Create Resource")
    }.to change(Resource, :count)
      .from(0).to(1)

    resource = Resource.find_by!(canonical_id: resource_attributes[:canonical_id])
    expect(resource.resource_groups).to match_array([resource_group])
    expect(resource.host_uris).to match_array(%w[http://example.com/abc http://example.com/xyz])

    expect(page).to have_current_path(resource_path(resource), ignore_query: true)
    expect(page).to have_content(resource.name)
  end
end
