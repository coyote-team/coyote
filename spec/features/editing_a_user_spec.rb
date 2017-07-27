RSpec.feature "Editing a user" do
  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    let!(:user) { create(:user) }

    it "succeeds" do
      # NOTE there is a bug where you can't add users, since there's no way to specify a password
      # once we can do that, easy to fill that part of the spec in
      click_first_link "Users"
      
      expect(page).to have_content(user.email)

      within "#user_#{user.id}" do
        click_link "Edit"
      end

      expect(page.current_path).to eq(edit_user_path(user))

      fill_in "First name", with: "Joe"

      expect {
        click_button "Update User"
        user.reload
      }.to change(user,:first_name).to("Joe")
    end
  end

  context "when logged-in as a user" do
    include_context "as a logged-in user"

    let(:user) { create(:user) }

    it "is not allowed" do
      expect(page).not_to have_link("Users")
      visit new_user_path
      expect(page.current_path).to eq(root_path)

      visit user_path(user)
      expect(page.current_path).to eq(root_path)

      visit edit_user_path(user)
      expect(page.current_path).to eq(root_path)
    end
  end
end
