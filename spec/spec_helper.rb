ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production? # Extra check to prevent database changes if the environment is production

require 'rspec/rails'
require 'factory_girl_rails'
require 'devise'
require 'webmock/rspec'
require 'capybara/rspec'
require 'simplecov'
require 'shoulda-matchers'
require 'airborne'
require 'vcr'
require 'pathname'
require 'database_cleaner'
require 'pry'
require 'pundit/matchers'

SPEC_DATA_PATH = Pathname(__dir__).join("data")

Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include Devise::Test::ControllerHelpers, :type => :helper
  config.include Coyote::Testing::FeatureHelpers, :type => :feature
  config.include Coyote::Testing::EmailHelpers, :type => :feature
  config.include Coyote::Testing::RequestHelpers, :type => :request
  config.include JSONAPI::RSpec, :type => :request

  config.render_views # see https://relishapp.com/rspec/rspec-rails/v/3-6/docs/controller-specs/render-views#render-views-globally

  config.order = "random"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching! 
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.use_transactional_fixtures = false
  config.default_formatter = "doc" if config.files_to_run.one?

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation,except: %w[ar_internal_metadata])
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each,:type => :feature) do
    ActionMailer::Base.deliveries.clear

    unless Capybara.current_driver == :rack_test
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy. With rack, we can get away with transactions.
      DatabaseCleaner.strategy = :truncation
    end
  end

  db_cleaning = ->(example) do
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each,:type => :controller,&db_cleaning) 
  config.around(:each,:type => :feature,&db_cleaning) 
  config.around(:each,:type => :request,&db_cleaning) 

  config.after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end
end

ActiveRecord::Migration.maintain_test_schema!

VCR.configure do |config|
  config.cassette_library_dir = "vcr"
  config.hook_into :webmock
  config.ignore_hosts "codeclimate.com"
end

WebMock.disable_net_connect!(allow: [/validator/,/codeclimate/])

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

SimpleCov.start do
  add_filter "/config/" # Ignores any file containing "/config/" in its path.
end

Rails.application.routes.default_url_options = { host: 'coyote.example' } # so serializable specs work
