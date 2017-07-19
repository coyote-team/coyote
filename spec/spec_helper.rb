require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
require "codeclimate-test-reporter"
require 'airborne'
require 'vcr'
require "pathname"

CodeClimate::TestReporter.start

Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Coyote::FeatureUserLogin, :type => :feature
  config.include Coyote::RequestHeaders
  config.include Coyote::RequestHeaders

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = 'random'

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  #config.disable_monkey_patching! 

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each,:type => :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    if !driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.before(:each,:type => [:request,:feature]) do
    DatabaseCleaner.start
  end

  config.append_after(:each,:type => [:request,:feature]) do
    DatabaseCleaner.clean
  end
end

SPEC_DATA_PATH = Pathname(__dir__).join("data")

VCR.configure do |config|
  config.cassette_library_dir = "vcr"
  config.hook_into :webmock
end

SimpleCov.start do
  add_filter "/config/" # Ignores any file containing "/config/" in its path.
end
