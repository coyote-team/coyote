RSpec.feature 'Representation filtering' do
  include_context 'as a logged-in author user'

  let!(:representation) do
    create(:representation,:not_approved,organization: user_organization,text: "My Organization's Description")
  end

  let!(:representation_search_target) do
    create(:representation,:approved,organization: user_organization,text: 'A woman smiling')
  end

  let!(:other_representation) do
    create(:representation,text: 'Should Not See This')
  end

  scenario 'succeeds' do
    click_first_link 'Descriptions'

    expect(page).to have_content("My Organization's Description")
    expect(page).not_to have_content('Should Not See This')

    fill_in 'q[text_or_resource_identifier_or_resource_title_cont_all]', with: 'smiling'
    click_button 'Search'

    expect(page).to have_content('A woman smiling')
    expect(page).not_to have_content("My Organization's Description")

    fill_in 'q[text_or_resource_identifier_or_resource_title_cont_all]', with: ''
    select 'Not Approved', from: 'q[status_eq]'
    click_button 'Search'

    expect(page).not_to have_content('A woman smiling')
    expect(page).to have_content("My Organization's Description")
  end
end
