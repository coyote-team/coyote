require_relative 'boot'
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

Bundler.require(*Rails.groups)
Dotenv.load

module Coyote
  class Application < Rails::Application
    config.load_defaults 5.1

    config.assets.precompile += %w[coyote_producer.js]
    config.eager_load_paths << Rails.root.join("lib") # http://blog.arkency.com/2014/11/dont-forget-about-eager-load-when-extending-autoload/
    config.autoload_paths << "#{Rails.root}/app/presenters"
    config.autoload_paths << "#{Rails.root}/app/services/"
    
    config.active_record.schema_format = :sql

    config.action_controller.per_form_csrf_tokens = true
    config.action_controller.forgery_protection_origin_check = true

    config.active_record.belongs_to_required_by_default = true
    
    # see https://github.com/elabs/pundit#rescuing-a-denied-authorization-in-rails
    config.action_dispatch.rescue_responses['Pundit::NotAuthorizedError'] = :forbidden
    config.action_dispatch.rescue_responses['Coyote::SecurityError']      = :forbidden
    
    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.test_framework :rspec
      g.fixture_replacement :factory_girl
      g.template_engine :haml
      g.factory_girl dir: Rails.root.join("spec/factories").to_s
    end

    config.x.site_name                       = ENV.fetch('COYOTE_SITE_NAME','Coyote')
    config.x.host_name                       = ENV.fetch('HOST','coyote.example.org')
    config.x.project_url                     = ENV.fetch('COYOTE_PROJECT_URL','http://coyote.pics')
    config.x.dashboard_top_items_queue_size  = ENV.fetch('COYOTE_DASHBOARD_TOP_ITEMS_QUEUE_SIZE',10).to_i
    config.x.default_email_from_address      = ENV.fetch('COYOTE_DEFAULT_EMAIL_FROM_ADDRESS',"support@#{config.x.host_name}")
    config.x.resource_api_page_size          = ENV.fetch('COYOTE_API_RESOURCE_PAGE_SIZE',50).to_i
    config.x.api_mime_type_template          = ENV.fetch('COYOTE_API_MIME_TYPE_TEMPLATE','application/vnd.coyote.%<version>s+json')
    config.x.maximum_login_attempts          = ENV.fetch('COYOTE_MAXIMUM_LOGIN_ATTEMPTS',5).to_i
    config.x.default_representation_language = ENV.fetch('COYOTE_DEFAULT_REPRESENTATION_LANGUAGE','en')
    config.x.unlock_user_accounts_after_this_many_minutes = ENV.fetch('COYOTE_UNLOCK_USER_ACCOUNTS_AFTER_THIS_MANY_MINUTES',10).to_i

    config.action_mailer.default_url_options = { host: config.x.host_name }

    config.action_mailer.smtp_settings = {
      user_name:            ENV.values_at('SENDGRID_USERNAME','MAIL_USER').compact.first || 'test_mail_user',
      password:             ENV.values_at('SENDGRID_PASSWORD','MAIL_PASSWORD').compact.first.to_s,
      domain:               ENV.fetch('MAIL_DOMAIN','coyote.example.com'),
      address:              ENV.fetch('MAIL_ADDRESS','smtp.example.com'),
      port:                 ENV.fetch('MAIL_PORT',587).to_i,
      authentication:       ENV.fetch('MAIL_AUTHENTICATION',:plain).to_sym,
      enable_starttls_auto: ENV.fetch('MAIL_ENABLE_STARTTLS_AUTO','true').downcase == 'true'
    }
  end
end
