RSpec.feature 'Resource adding and changing' do
  include_context 'as a logged-in editor user'

  let!(:resource_group) { create(:resource_group, organization: user_organization) }

  let(:resource_attributes) do
    attributes_for(:resource).tap(&:symbolize_keys!).merge(title: title)
  end

  scenario 'succeeds' do
    click_first_link "Resources"
    click_first_link("New Resource")

    select(resource_group.title, from: 'Resource Group', :match => :first)

    fill_in "Identifier",   with: resource_attributes[:identifier]
    fill_in "Caption",      with: resource_attributes[:title]
    fill_in "Canonical ID", with: resource_attributes[:canonical_id]
    fill_in "Host URIs",    with: "http://example.com/abc\nhttp://example.com/xyz"

    select(resource_attributes[:resource_type], from: 'Type')

    expect {
      click_button('Save')
    }.to change(Resource, :count).
      from(0).to(1)

    resource = Resource.find_by!(identifier: resource_attributes[:identifier])
    expect(resource.host_uris).to match_array(%w[http://example.com/abc http://example.com/xyz])

    expect(page.current_path).to eq(resource_path(resource))
    expect(page).to have_content(resource.title)
  end
end
