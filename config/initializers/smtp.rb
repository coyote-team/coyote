# frozen_string_literal: true

# Configure SMTP
Rails.application.configure do
  tls = Credentials.dig(:mailer, :tls).to_s == "true"
  config.action_mailer.smtp_settings = {
    user_name:            Credentials.dig(:mailer, :user),
    password:             Credentials.dig(:mailer, :password),
    domain:               Credentials.dig(:mailer, :domain),
    address:              Credentials.dig(:mailer, :host),
    port:                 Credentials.dig(:mailer, :port).to_i,
    authentication:       Credentials.dig(:mailer, :authentication)&.to_sym,
    enable_starttls_auto: Credentials.dig(:mailer, :enable_starttls_auto).to_s == "true",
    tls:                  tls,
    ssl:                  tls,
  }
end
