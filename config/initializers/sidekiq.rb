# frozen_string_literal: true

redis_namespace = "coyote-#{ENV["STAGING"] ? "staging" : Rails.env}"
REDIS_POOL = ConnectionPool.new(size: 10) {
  Redis.new(
    connect_timeout:    1,
    namespace:          redis_namespace,
    reconnect_attempts: 3,
    ssl_params:         {verify_mode: OpenSSL::SSL::VERIFY_NONE},
    url:                ENV["REDIS_URL"],
  )
}

Sidekiq.configure_server do |config|
  config.redis = REDIS_POOL
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_POOL
end
