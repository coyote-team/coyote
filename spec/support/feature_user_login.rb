module Coyote
  # Methods to facilitate writing Capybara specs
  module FeatureUserLogin
    # Login to the app
    # @param user [User] the user to login
    # @param password [Password] the password to use
    def login(user = create(:user),password = "")
      visit login_path

      within(".new_user") do
        fill_in "Email", with: user.email
        fill_in "Password", with: password
      end

      # When admins login, the system calls out to Travis; we record that interaction to make our tests
      # deterministic
      VCR.use_cassette "Travis CI build notification check" do
        click_button "Log in"
      end
    end

    # Completes a user's session
    def logout
      click_link "Log out"
    end
  end
end
