ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?  # Extra check to prevent database changes if the environment is production

require 'rspec/rails'
require 'devise'
require 'webmock/rspec'
require 'capybara/rspec'
require "codeclimate-test-reporter"
require 'airborne'
require 'vcr'
require "pathname"

SPEC_DATA_PATH = Pathname(__dir__).join("data")

CodeClimate::TestReporter.start
Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Coyote::FeatureUserLogin, :type => :feature
  config.include Coyote::RequestHeaders
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
  config.include Devise::TestHelpers, :type => :view

  config.order = "random"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching! 
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.use_transactional_fixtures = false

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each,:type => :feature) do
    unless Capybara.current_driver == :rack_test
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy. With rack, we can get away with transactions.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.around(:each,type: %i(request feature)) do |example|
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end
end

ActiveRecord::Migration.maintain_test_schema!

VCR.configure do |config|
  config.cassette_library_dir = "vcr"
  config.hook_into :webmock
  config.ignore_hosts "codeclimate.com"
end

SimpleCov.start do
  add_filter "/config/" # Ignores any file containing "/config/" in its path.
end
