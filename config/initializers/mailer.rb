ActionMailer::Base.smtp_settings = {
  user_name:            ENV.values_at('SENDGRID_USERNAME','MAIL_USER').compact.first || 'test_mail_user',
  password:             ENV.values_at('SENDGRID_PASSWORD','MAIL_PASSWORD').compact.first.to_s,
  domain:               ENV.fetch('MAIL_DOMAIN','coyote.example.com'),
  address:              ENV.fetch('MAIL_ADDRESS','smtp.example.com'),
  port:                 ENV.fetch('MAIL_PORT',587).to_i,
  authentication:       ENV.fetch('MAIL_AUTHENTICATION',:plain).to_sym,
  enable_starttls_auto: ENV.fetch('MAIL_ENABLE_STARTTLS_AUTO','true').downcase == 'true'
}
