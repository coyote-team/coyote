# frozen_string_literal: true

require_relative "boot"

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Ensure Ransack uses Simpleform: https://github.com/activerecord-hackery/ransack#using-simpleform
ENV["RANSACK_FORM_BUILDER"] = "::SimpleForm::FormBuilder"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Coyote
  class Application < Rails::Application
    autoload :Credentials, Rails.root.join("lib", "credentials")

    config.before_configuration do
      config.sass.preferred_syntax = :sass
    end

    config.load_defaults 6.0

    config.eager_load_paths << Rails.root.join("lib") # http://blog.arkency.com/2014/11/dont-forget-about-eager-load-when-extending-autoload/

    config.active_record.schema_format = :ruby

    config.action_controller.per_form_csrf_tokens = true
    config.action_controller.forgery_protection_origin_check = true

    config.active_record.belongs_to_required_by_default = true

    # see https://github.com/elabs/pundit#rescuing-a-denied-authorization-in-rails
    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden
    config.action_dispatch.rescue_responses["Coyote::SecurityError"] = :forbidden

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.template_engine :slim
      g.factory_bot dir: Rails.root.join("spec", "factories").to_s
    end

    # Prevent Rails from messing up generated URLs in the API
    config.active_support.escape_html_entities_in_json = false

    # Configure the application per credentials and/or ENV variables
    config.secret_key_base = Credentials.fetch(:secret_key_base) do
      abort(%(Please set `secret_key_base` in the app's encrypted credentials or in ENV["SECRET_KEY_BASE"]))
    end

    config.x.site_name = Credentials.fetch(:app, :name) { "Coyote" }
    config.x.host_name = Credentials.fetch(:app, :host) { "coyote.example.org" }
    config.x.project_url = Credentials.fetch(:app, :project_url) { "https://coyote.pics" }
    config.x.dashboard_top_items_queue_size = 10
    config.x.default_email_from_address = Credentials.fetch(:mailer, :sender) { "support@#{config.x.host_name}" }
    config.x.resource_api_page_size = ENV.fetch("COYOTE_API_RESOURCE_PAGE_SIZE", 50).to_i
    config.x.api_mime_type_template = ENV.fetch("COYOTE_API_MIME_TYPE_TEMPLATE", "application/vnd.coyote.%<version>s+json")
    config.x.maximum_login_attempts = ENV.fetch("COYOTE_MAXIMUM_LOGIN_ATTEMPTS", 5).to_i
    config.x.default_representation_language = ENV.fetch("COYOTE_DEFAULT_REPRESENTATION_LANGUAGE", "en")
    config.x.unlock_user_accounts_after_this_many_minutes = ENV.fetch("COYOTE_UNLOCK_USER_ACCOUNTS_AFTER_THIS_MANY_MINUTES", 10).to_i

    config.action_mailer.default_url_options = {host: config.x.host_name}
  end
end
