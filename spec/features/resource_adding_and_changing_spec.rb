# frozen_string_literal: true

RSpec.describe "Resource adding and changing" do
  include_context "with a logged-in editor user"

  let!(:resource_group) { create(:resource_group, organization: user_organization) }

  let(:resource_attributes) do
    attributes_for(:resource, canonical_id: "abc123").symbolize_keys
  end

  it "succeeds" do
    click_first_link "Resources"
    click_first_link("Add Resource")

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

    expect {
      click_button("Create Resource")
    }.to change(Resource, :count)
      .from(0).to(1)

    resource = Resource.find_by!(canonical_id: resource_attributes[:canonical_id])
    expect(resource.resource_groups).to match_array([resource_group])
    expect(resource.host_uris).to match_array(%w[http://example.com/abc http://example.com/xyz])

    expect(page).to have_current_path(resource_path(resource, organization_id: user_organization), ignore_query: true)
    expect(page).to have_content(resource.name)
  end

  context "when invalid resource attributes are submitted" do
    describe 'source URI is invalid' do
      let!(:resource) { create(:resource, organization_id: user_organization.id) }
      let(:resource_uri) { resource.source_uri }

      it "should display an error message and re-render the form" do
        click_first_link "Resources"
        click_first_link("Add Resource")

        fill_in "Caption", with: resource_attributes[:name]
        fill_in "Canonical ID", with: resource_attributes[:canonical_id]
        fill_in "Source URI", with: "Hello World!"
        fill_in "Host URIs", with: "http://example.com/abc\nhttp://example.com/xyz"
        click_button("Create Resource")

        expect(page).to have_current_path(resources_path(organization_id: user_organization))
        expect(page).to have_content("The Source URI is invalid.")
      end
    end

    describe 'source uri is not unique' do
      let!(:resource) { create(:resource, organization_id: user_organization.id) }
      let(:resource_uri) { resource.source_uri }

      it "should display an error message and re-render the form" do
        click_first_link "Resources"
        click_first_link("Add Resource")

        fill_in "Caption", with: resource_attributes[:name]
        fill_in "Canonical ID", with: resource_attributes[:canonical_id]
        fill_in "Source URI", with: resource_uri
        fill_in "Host URIs", with: "http://example.com/abc\nhttp://example.com/xyz"
        click_button("Create Resource")
    
        expect(page).to have_current_path(resources_path(organization_id: user_organization))
        expect(page).to have_content("The Source URI is already in use for this organization.")
      end
    end
  end
end
