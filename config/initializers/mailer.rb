ActionMailer::Base.smtp_settings = {
  :user_name => ENV['MAIL_USER'],
  :password => ENV['MAIL_PASSWORD'], 
  :domain => ENV['MAIL_DOMAIN'],
  :address => ENV['MAIL_ADDRESS'],
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
