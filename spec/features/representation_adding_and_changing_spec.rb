RSpec.feature 'Representation adding and changing' do
  include_context 'as a logged-in editor user'

  let(:resource) do 
    create(:resource,organization: user_organization)
  end

  let!(:metum) { create(:metum,:long,organization: user_organization) }
  let!(:license) { create(:license) }
  let!(:endpoint) { create(:endpoint) }

  scenario 'succeeds' do
    visit resource_url(resource)

    click_first_link('Create Description')
    expect(page.current_path).to eq(new_organization_representation_path(user_organization))

    new_text = attributes_for(:representation).fetch(:text)

    fill_in 'Text', with: new_text
    select metum.title, from: 'Metum'

    expect {
      click_button('Save')
    }.to change(resource.representations,:count).
      from(0).to(1)

    representation = resource.representations.first
    expect(page.current_path).to eq(representation_path(representation))
    expect(page).to have_content(representation.text)

    click_first_link 'Edit'
    expect(page.current_path).to eq(edit_representation_path(representation))

    fill_in 'Text', with: 'XYZ123'

    expect {
      click_button('Save')
      expect(page.current_path).to eq(representation_path(representation))
      representation.reload
    }.to change(representation,:text).
      to('XYZ123')

    click_first_link 'Descriptions'
    expect(page.current_path).to eq(organization_representations_path(user_organization))

    expect(page).to have_content(resource.title)

    expect {
      click_first_link('Delete')
    }.to change { Representation.exists?(representation.id) }.
      from(true).to(false)

    expect(page.current_path).to eq(organization_representations_path(user_organization))
  end
end
