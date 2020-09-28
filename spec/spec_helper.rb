# frozen_string_literal: true

require "simplecov"
require "simplecov-material"

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::MaterialFormatter,
])

SimpleCov.start "rails" do
  # Organize coverage of the `app` folder a little bit better
  app = File.join(Dir.pwd, "app")
  Dir[File.join(app, "*")].each do |folder|
    folder = File.basename(folder)
    name = folder
      .split("_")
      .inject("") { |whole, part| [whole, part[0].upcase + part[1..-1]].join(" ").strip }

    next if folder == "views" || groups[name]

    paths = [File.join("app", folder)]
    add_group name, paths
  end

  groups.delete("Jobs")
  self.groups = Hash[*groups.sort.flatten]
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production? # Extra check to prevent database changes if the environment is production

require "rspec/rails"
require "factory_bot_rails"
require "jsonapi/rspec"
require "pathname"
require "pry"
require "pundit/matchers"
require "rails-controller-testing"
require "shoulda-matchers"
require "webmock/rspec"

SPEC_DATA_PATH = Pathname(__dir__).join("data")

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |file| require file }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Coyote::Testing::RescuingErrors
  config.include Coyote::Testing::ControllerHelpers, type: :controller
  config.include Coyote::Testing::FeatureHelpers, type: :feature
  config.include Coyote::Testing::EmailHelpers, type: :feature
  config.include Coyote::Testing::ApiHelpers, type: :request
  config.include JSONAPI::RSpec, type: :request

  %i[controller view request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, type: type
    config.include ::Rails::Controller::Testing::TemplateAssertions, type: type
    config.include ::Rails::Controller::Testing::Integration, type: type
  end

  config.render_views # see https://relishapp.com/rspec/rspec-rails/v/3-6/docs/controller-specs/render-views#render-views-globally

  config.order = "random"
  config.filter_run focus: true
  config.filter_run show_in_doc: true if ENV["APIPIE_RECORD"] # see https://github.com/Apipie/apipie-rails#examples-recording
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.use_transactional_fixtures = true
  config.default_formatter = "doc" if config.files_to_run.one?

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each, type: :feature) do
    ActionMailer::Base.deliveries.clear
  end
end

# ActiveRecord::Migration.maintain_test_schema!

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
