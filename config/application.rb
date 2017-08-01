require File.expand_path('../boot', __FILE__)
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'
Bundler.require(:default, Rails.env)
Dotenv.load
require 'csv'
require 'iconv'
require_relative '../lib/ext/active_record'

module Coyote
  class Application < Rails::Application
    # Pulls in values from config_secure for initialization
    config.before_configuration do
      config.sass.preferred_syntax = :sass
    end
    config.assets.precompile += %w[coyote_producer.js]
    
    config.autoload_paths << "#{Rails.root}/lib"

    # after_commit etc. callback transaction errors will raise
    config.active_record.raise_in_transactional_callbacks = true

    config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    ActsAsTaggableOn.remove_unused_tags = true
    ActsAsTaggableOn.force_lowercase = true
    ActsAsTaggableOn.force_parameterize = true

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.test_framework :rspec
      g.fixture_replacement :factory_girl
      g.template_engine :haml
      g.factory_girl dir: Rails.root.join("spec/factories")
    end

    config.x.site_name = ENV.fetch("COYOTE_SITE_NAME","Coyote")
  end
end
