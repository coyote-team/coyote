# frozen_string_literal: true

class Credential < OpenStruct
  def self.load(path, key_path: path, env_name: path.split("/").last)
    env_name = "RAILS_#{env_name.to_s.upcase}_KEY"
    Rails.application.encrypted(
      "config/#{path}.yml.enc",
      key_path: "config/#{key_path}.key",
      env_key:  ENV[env_name].present? ? env_name : "_____NO_KEY",
    ).config.symbolize_keys
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    Rails.logger.warn "[Credentials] Invalid key for `#{env_name}'; could not load credentials at config/#{path}.yml.enc with key file config/#{key_path}.key or ENV key #{env_name}"
    {}
  end

  def initialize(attributes = {})
    super {}
    attributes.each do |key, value|
      send("#{key}=", value.is_a?(Hash) ? Credential.new(value) : value)
    end
  end

  def dig(*keys)
    env_keys = keys.first.to_s == "app" ? keys[1..-1] : keys
    ENV.fetch(env_keys.join("_").upcase) do
      value = self
      keys.each do |key|
        value = value.send(key)
        break if value.blank?
      end

      value
    end
  end

  def fetch(*keys)
    dig(*keys) || yield
  end
end

# Credentials are applied in the following order:
# 1. Base
# 2. RAILS_ENV specific
# 3. Staging specific (if a STAGING flag is given)
base_config = Credential.load("credentials", key_path: "master", env_name: "base")
env_config = Credential.load("credentials/#{Rails.env}", env_name: "master") # Rails.application.credentials.config.symbolize_keys
staging_config = ENV["STAGING"].present? ? Credential.load("credentials/staging") : {}

env_config = env_config.deep_merge(staging_config)

Credentials = Credential.new(base_config.deep_merge(env_config))
