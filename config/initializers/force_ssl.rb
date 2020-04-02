# frozen_string_literal: true

if Rails.application.config.force_ssl
  Rails.application.routes.default_url_options[:protocol] = "https"
end
