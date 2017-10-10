RSpec.feature 'Logging in and out' do
  let(:password) { 'abc123PDQ' }

  let!(:user) do 
    create(:user,:with_membership,password: password) 
  end

  scenario 'Logging in with correct credentials and logging out' do
    login(user,password)
    expect(page.status_code).to eq(200)
    expect(page).to have_content 'Signed in successfully'

    user.organizations.each do |org|
      expect(page).to have_content(org.title)
    end

    logout

    expect(page).to have_content 'Signed out successfully'
    visit organization_resources_path(user.organizations.first)
    expect(page.current_path).to eq(new_user_session_path)
  end

  scenario 'Logging in with the wrong password' do
    login(user,'BAD_PASSWORD',false)
    expect(page.status_code).to eq(200)
    expect(page).to have_content 'Invalid Email or password'
  end
end
