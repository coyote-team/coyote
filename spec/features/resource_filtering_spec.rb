RSpec.feature 'Resource viewing' do
  include_context 'as a logged-in author user'

  let!(:resource) do
    create(:resource, organization: user_organization, title: "My Organization's Resource")
  end

  let!(:cezannne_resource) do
    create(:resource, organization: user_organization, title: 'Painting by Cezanne')
  end

  let!(:other_resource) do
    create(:resource, title: 'Should Not See This')
  end

  scenario 'succeeds' do
    click_first_link 'Resources'

    expect(page).to have_content("My Organization's Resource")
    expect(page).not_to have_content('Should Not See This')

    fill_in 'q[canonical_id_or_identifier_or_title_or_representations_text_cont_all]', with: 'cezanne'
    click_button 'Search'

    expect(page).to have_content('Painting by Cezanne')
    expect(page).not_to have_content("My Organization's Resource")
  end
end
