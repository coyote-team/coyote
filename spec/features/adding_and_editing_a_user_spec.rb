RSpec.feature 'Adding an editing a user' do
  context 'when logged-in as an admin' do
    include_context 'as a logged-in admin user'

    let!(:foreign_user) { create(:user) }

    it 'succeeds' do
      click_first_link 'Users'

      expect(current_path).to eq(organization_users_path(user_organization))
      expect(page).not_to have_content(foreign_user.email)

      click_first_link 'New User'
      expect(current_path).to eq(new_organization_user_path(user_organization))
      
      fill_in "user[first_name]",              with: "Charlie"
      fill_in "user[last_name]",               with: "Kelly"
      fill_in "user[email]",                   with: "charlie@example.com"
      fill_in "user[password]",                with: "xyzpdq123"
      select  "Editor",                        from: "Role"

      expect {
        click_button "Save User"
      }.to change(user_organization.users,:count).
        from(1).to(2)

      expect(page).to have_content("Charlie Kelly was successfully added")

      new_user = User.find_by!(email: "charlie@example.com")
      expect(current_path).to eq(organization_user_path(user_organization,new_user))

      expect(new_user).to be_editor

      click_first_link 'Users'
      expect(page).to have_content("charlie@example.com")

      within "#user_#{new_user.id}" do
        click_link 'Edit'
      end

      expect(page.current_path).to eq(edit_organization_user_path(user_organization,new_user))

      fill_in 'First name', with: 'Joe'

      expect {
        click_button 'Save User'
        new_user.reload
      }.to change(new_user,:first_name).
        from('Charlie').
        to('Joe')
    end
  end

  context 'when logged-in as a regular user' do
    include_context 'as a logged-in user'

    let(:another_user) { create(:user,:with_membership) }
    let(:another_user_organization) { another_user.organizations.first }

    it 'is not allowed' do
      expect(page).not_to have_link('Users')

      visit new_organization_user_path(user_organization)
      expect(page).to have_content('You are not authorized')

      visit organization_user_path(user_organization,user)
      expect(page).to have_content('You are not authorized')
      
      visit edit_organization_user_path(user_organization,user)
      expect(page).to have_content('You are not authorized')

      expect {
        visit new_organization_user_path(another_user_organization)
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect {
        visit organization_user_path(another_user_organization,another_user)
      }.to raise_error(ActiveRecord::RecordNotFound)
      
      expect {
        visit edit_organization_user_path(another_user_organization,another_user)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
