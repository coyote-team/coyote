module Coyote
  # Methods to facilitate writing Capybara specs
  module FeatureUserLogin
    # Login to the app
    # @param user [User] the user to login
    # @param password [Password] the password to use
    def login(user = create(:user),password = "")
      visit "/login"

      within(".new_user") do
        fill_in "Email", with: user.email
        fill_in "Password", with: password
      end

      click_button "Log in"
    end

    # Completes a user's session
    def logout
      click_link "Log out"
    end
  end
end
