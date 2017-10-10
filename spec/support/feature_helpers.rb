module Coyote
  module Testing
    # Raises when there is an attempt to click a link that cannot be found
    MissingLink = Class.new(StandardError)

    # Methods to facilitate writing Capybara specs
    module FeatureHelpers
      # Login to the app
      # @param user [User] the user to login
      # @param password [Password] the password to use
      # @password check_success [Boolean] whether to automatically check for login success (useful for testing login failure paths, defaults to true)
      def login(user = create(:user),password = '',check_success = true)
        visit new_user_session_path

        within('.new_user') do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: password
        end

        click_button 'Log in'
        expect(page).to have_content('Signed in successfully') if check_success
      end

      # Ends a user's session
      def logout
        click_link 'Log out'
      end

      # Sometimes we have pages with mulitiple copies of the same link; this lets you pick the first one without fuss
      # @param [String] name of the link to lookup
      # @raise [MissingLink] if we can't find the link
      def click_first_link(link_name)
        link = first(:link,link_name)
        raise MissingLink, "cannot find a link named '#{link_name}'" unless link
        link.click
      end

      # Lets us view the currently-rendered page in a context where JS and CSS will work
      # @see https://coderwall.com/p/jsutlq/capybara-s-save_and_open_page-with-css-and-js
      def show_page
        save_page Rails.root.join('public','.capybara.html')
        `launchy http://localhost:#{ENV.fetch('PORT',3000)}/.capybara.html`
      end
    end
  end
end
