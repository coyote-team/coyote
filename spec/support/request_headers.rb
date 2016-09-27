module RequestHeaders
  def set_headers(authentication_token)
    app_secret = 'secretkey'
    ENV['TT_SECRET'] = app_secret
    {
      'tt-app-secret' => app_secret,
      'tt-authentication-token' => authentication_token,
      'Content-Type' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include RequestHeaders
end
