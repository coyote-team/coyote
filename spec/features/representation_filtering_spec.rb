RSpec.feature 'Representation filtering' do
  include_context 'as a logged-in author user'

  let!(:representation) do 
    create(:representation,organization: user_organization,text: "My Organization's Representation")
  end

  let!(:other_representation) do 
    create(:representation,text: 'Should Not See This')
  end

  scenario 'succeeds', :focus do
    click_link 'Representations'
    expect(page).to have_content("My Organization's Representation")
    expect(page).not_to have_content('Should Not See This')
  end

  skip 'also need to setup basic representation search'
end
