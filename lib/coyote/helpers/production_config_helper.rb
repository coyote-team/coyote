# frozen_string_literal: true

module Coyote
  module Helpers
    module ProductionConfigHelper
      def self.redis_cache_config
        env_url = ENV["REDIS_CACHE_URL"]
        redis_cache_url = env_url || Credentials.dig(:cache, :redis_url)

        if redis_cache_url.nil?
          return nil
        end

        error_handler = ->(method:, returning:, exception:) {
          if defined?(Appsignal)
            Appsignal.set_error(exception) do |transaction|
              transaction.set_tags(method: method, returning: returning)
            end
          else
            logger.error("Redis cache exception: #{method}, #{returning}, #{exception}")
          end
        }

        {
          namespace:          ENV["STAGING"].present? ? "staging" : "production",
          url:                redis_cache_url,
          error_handler:      error_handler,
          connect_timeout:    5, # Defaults to 20 seconds
          read_timeout:       0.2, # Defaults to 1 second
          write_timeout:      0.2, # Defaults to 1 second
          reconnect_attempts: 0, # Defaults to 0
        }
      end
    end
  end
end
