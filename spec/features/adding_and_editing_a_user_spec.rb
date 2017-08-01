RSpec.feature "Editing a user" do
  context "when logged-in as an admin" do
    include_context "as a logged-in admin user"

    let!(:other_user) { create(:user) }

    it "succeeds" do
      click_first_link "Users"
      
      expect(page).to have_content(other_user.email)

      within "#user_#{other_user.id}" do
        click_link "Edit"
      end

      expect(page.current_path).to eq(edit_user_path(other_user))

      fill_in "First name", with: "Joe"

      expect {
        click_button "Update User"
        other_user.reload
      }.to change(other_user,:first_name).to("Joe")

      skip "can't test adding a user yet"
    end
  end

  context "when logged-in as a user" do
    include_context "as a logged-in user"

    let(:user) { create(:user) }

    it "is not allowed" do
      expect(page).not_to have_link("Users")
      visit new_user_path
      expect(page.current_path).to eq(new_user_session_path)

      visit user_path(user)
      expect(page.current_path).to eq(new_user_session_path)

      visit edit_user_path(user)
      expect(page.current_path).to eq(new_user_session_path)
    end
  end
end
