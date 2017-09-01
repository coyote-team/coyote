require_relative 'boot'
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

Bundler.require(*Rails.groups)
Dotenv.load

module Coyote
  class Application < Rails::Application
    config.before_configuration do
      config.sass.preferred_syntax = :sass
    end

    config.load_defaults 5.1

    config.assets.precompile += %w[coyote_producer.js]
    config.autoload_paths << "#{Rails.root}/lib"
    config.autoload_paths << "#{Rails.root}/app/presenters"

    config.active_record.schema_format = :sql

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

    config.x.site_name                      = ENV.fetch("COYOTE_SITE_NAME","Coyote")
    config.x.dashboard_top_items_queue_size = ENV.fetch("COYOTE_DASHBOARD_TOP_ITEMS_QUEUE_SIZE",10).to_i
  end
end
