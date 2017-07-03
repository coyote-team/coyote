require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rspec'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  #http://dchua.com/2013/08/19/dry-up-your-devise-logins-in-rspec/
  config.include Devise::TestHelpers, type: :controller
  config.include ControllerMacros, :type => :controller

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.fail_fast = true
  #config.fail_fast = false
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
  config.use_transactional_fixtures = false
end

#Test coverage
SimpleCov.start do
  add_filter "/config/" # Ignores any file containing "/config/" in its path.
end
