# frozen_string_literal: true

require "capybara"
require "capybara/rspec"
require "capybara/webmock"
require "selenium/webdriver"
require "webdrivers"

# Prefer exact matches when selecting form elements
Capybara.match = :prefer_exact

headless = :chrome_headless
ui = :chrome
options = {
  browser: :chrome,
}
chromium_binary = `which chromium-browser`
options[:binary] = chromium_binary if chromium_binary.present?

## Headless Chrome (default)
# Use a headless Chrome browser for TDD (when we don't want to be interrupted by the UI).
# Add a `UI=1` before `bundle exec rspec` to prevent this from happening. We're using a custom
# browser because we want to ensure the window size is large enough for testing in desktop mode.
Capybara.register_driver headless do |app|
  chrome_options = Capybara::Webmock.chrome_options
  chrome_options.add_argument("headless")
  chrome_options.add_argument("window-size=1280,800")
  Capybara::Selenium::Driver.new(app, options.merge(options: chrome_options))
end

## Chrome w/UI (optional)
# Use a standard Chrome browser for tests where we'd like to watch the UI. Opt-in w/the `ui: true`
# flag in your examples, or with a universal `UI=true bundle exec rspec` ENV flag.
Capybara.register_driver ui do |app|
  chrome_options = Capybara::Webmock.chrome_options
  Capybara::Selenium::Driver.new(app, options.merge(options: chrome_options))
end

Capybara.javascript_driver = ENV["UI"] ? ui : headless
Capybara.server = :puma, {Silent: true}

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
  end

  config.after(:suite) do
    Capybara::Webmock.stop
  end
end
