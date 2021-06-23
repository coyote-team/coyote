# frozen_string_literal: true

redis_namespace = "#{Rails.env}-#{ENV["STAGING"] ? "staging" : Rails.env}"

Sidekiq.configure_server do |config|
  config.redis = {
    namespace: redis_namespace,
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    namespace: redis_namespace,
  }
end
