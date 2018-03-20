Coyote::Application.config.secret_key_base  = ENV.fetch("SECRET_KEY_BASE") do
  abort("Please set ENV variable SECRET_KEY_BASE (see .env file)")
end
