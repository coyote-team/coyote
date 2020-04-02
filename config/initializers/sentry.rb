# frozen_string_literal: true

sentry_dsn = Credentials.dig(:sentry, :dsn)

if defined?(Raven) && sentry_dsn.present?
  Raven.configure do |config|
    config.dsn = sentry_dsn
    config.current_environment = ENV["STAGING"].present? ? "staging" : "production"
  end
end
