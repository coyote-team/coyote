# frozen_string_literal: true

require "capybara"
require "capybara/rspec"
require "capybara/webmock"
require "selenium/webdriver"
require "webdrivers"

# Basic Capybara configuration
Capybara.match = :prefer_exact
Capybara.server = :puma, {Silent: true}
Capybara.server_host = ENV["TEST_HOST"] if ENV["TEST_HOST"].present?

## DRIVERS
# First, set up some basic options
chrome = :chrome
chrome_headless = :chrome_headless
chrome_arguments = %w[
  disable-gpu no-sandbox window-size=1280,800
]

# In the event we're pointing to a remote Selenium host, we want to use a remote driver that supports Chrome
selenium_host = ENV["SELENIUM_HOST"]
driver_options = selenium_host.blank? ? {browser: :chrome} : {
  browser:              :remote,
  desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(chromeOptions: {args: chrome_arguments}),
  url:                  "http://#{selenium_host}/wd/hub",
}

## Headless Chrome (default)
# Use a headless Chrome browser for TDD (when we don't want to be interrupted by the UI).
# Add a `UI=1` before `bundle exec rspec` to prevent this from happening. We're using a custom
# browser because we want to ensure the window size is large enough for testing in desktop mode.
Capybara.register_driver chrome_headless do |app|
  options = Capybara::Webmock.chrome_options
  options.add_argument("headless")
  chrome_arguments.each do |argument|
    options.add_argument(argument)
  end

  Capybara::Selenium::Driver.new(app, driver_options.merge(options: options))
end

## Chrome w/UI (optional)
# Use a standard Chrome browser for tests where we'd like to watch the UI. Opt-in w/the `ui: true`
# flag in your examples, or with a universal `UI=true bundle exec rspec` ENV flag.
Capybara.register_driver chrome do |app|
  options = Capybara::Webmock.chrome_options
  chrome_arguments.each do |argument|
    options.add_argument(argument)
  end

  Capybara::Selenium::Driver.new(app, driver_options.merge(options: options))
end

Capybara.javascript_driver = ENV["UI"] ? chrome : chrome_headless

RSpec.configure do |config|
  config.before(type: :feature) do |example|
    Capybara::Webmock.start
    Capybara.current_driver = if example.metadata[:ui]
      ui
    elsif example.metadata[:javascript]
      Capybara.javascript_driver
    else
      Capybara.default_driver
    end

    if selenium_host.present?
      server = Capybara.current_session.server
      Capybara.app_host = server ? "http://#{server.host}:#{server.port}" : "http://localhost:3030"
    end
  end

  config.after(type: :feature) do
    Capybara.reset_sessions!
    Capybara.use_default_driver
    Capybara.app_host = nil
  end

  config.after(:suite) do
    Capybara::Webmock.stop
  end
end
