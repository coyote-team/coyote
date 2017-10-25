RSpec.feature 'Resource viewing' do
  include_context 'as a logged-in author user'

  let!(:resource) do 
    create(:resource,organization: user_organization,title: "My Organization's Resource")
  end

  let!(:other_resource) do 
    create(:resource,title: 'Should Not See This')
  end

  scenario 'succeeds' do
    click_link 'Resources'
    expect(page).to have_content("My Organization's Resource")
    expect(page).not_to have_content('Should Not See This')
  end

  pending 'need to check search and pagination here!'
end
