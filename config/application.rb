require File.expand_path('../boot', __FILE__)
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

Bundler.require(:default,Rails.env)
Dotenv.load
require 'csv'
require 'iconv'
require_relative '../lib/ext/active_record'

module Coyote
  class Application < Rails::Application
    config.before_configuration do
      config.sass.preferred_syntax = :sass
    end

    config.assets.precompile += %w[coyote_producer.js]
    config.autoload_paths << "#{Rails.root}/lib"

    config.active_record.schema_format = :sql

    config.lograge.enabled = true
    
    config.action_controller.per_form_csrf_tokens = true
    config.action_controller.forgery_protection_origin_check = true

    Rails.application.config.active_record.belongs_to_required_by_default = true
    
    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.test_framework :rspec
      g.fixture_replacement :factory_girl
      g.template_engine :haml
      g.factory_girl dir: Rails.root.join("spec/factories").to_s
    end

    config.x.site_name = ENV.fetch("COYOTE_SITE_NAME","Coyote")
  end
end
