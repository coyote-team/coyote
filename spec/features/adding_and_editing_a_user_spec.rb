RSpec.feature 'Editing a user' do
  context 'when logged-in as an admin' do
    include_context 'as a logged-in admin user'

    let!(:other_user) do 
      user.organization.create!(attributes_for(:user))
    end

    let!(:foreign_user) { create(:user) }

    it 'succeeds' do
      click_first_link 'Users'
      
      expect(page).to have_content(other_user.email)
      expect(page).not_to have_content(foreign_user.email)

      within "#user_#{other_user.id}" do
        click_link 'Edit'
      end

      expect(page.current_path).to eq(edit_user_path(other_user))

      fill_in 'First name', with: 'Joe'

      expect {
        click_button 'Update User'
        other_user.reload
      }.to change(other_user,:first_name).to('Joe')
    end
  end

  context 'when logged-in as a regular user' do
    include_context 'as a logged-in user'

    let(:another_user) { create(:user) }

    it 'is not allowed', :focus do
      expect(page).not_to have_link('Users')
      visit new_user_path
      expect(page).to have_content('You are not authorized')

      [user,another_user].each do |u|
        visit user_path(u)
        expect(page).to have_content('You are not authorized')

        visit edit_user_path(u)
        expect(page).to have_content('You are not authorized')
      end
    end
  end
end
