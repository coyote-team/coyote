if Rails.application.config.force_ssl
  Rails.application.routes.default_url_options[:protocol] = 'https'
end
