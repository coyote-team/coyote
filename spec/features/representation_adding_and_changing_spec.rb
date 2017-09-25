RSpec.feature 'Representation adding and changing', :focus do
  include_context 'as a logged-in editor user'

  let(:resource) do 
    create(:resource,organization: user_organization)
  end

  let!(:metum) { create(:metum,:long,organization: user_organization) }
  let!(:license) { create(:license) }

  scenario 'succeeds', :focus do
    visit organization_resource_url(user_organization,resource)

    click_first_link('Create Representation')
    expect(page.current_path).to eq(new_organization_representation_path(user_organization))

    fill_in 'Text', with: attributes_for(:representation).fetch(:text)
    select metum.title, from: 'Metum'

    expect {
      click_button('Save')
    }.to change(resource.representations,:count).
      from(0).to(1)

    representation = resource.representations.first
    expect(page.current_path).to eq(organization_representation_path(user_organization,representation))
    expect(page).to have_content(representation.text)

    click_first_link 'Edit'
    expect(page.current_path).to eq(edit_organization_representation_path(user_organization,representation))

    fill_in 'Text', with: 'XYZ123'

    expect {
      click_button('Save')
      expect(page.current_path).to eq(organization_representation_path(user_organization,representation))
      representation.reload
    }.to change(representation,:text).
      to('XYZ123')

    click_first_link 'Representations'
    expect(page.current_path).to eq(organization_representations_path)

    pending 'view index page showing new representation'
    pending 'deleting a representation'
  end
end
