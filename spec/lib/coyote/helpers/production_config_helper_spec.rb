# frozen_string_literal: true

require "spec_helper"

ENV_URL_KEY = "REDIS_CACHE_URL"
ENV_URL_VALUE = "env_redis_cache_url"
CRED_URL_VALUE = "cred_redis_cache_url"

RSpec.describe Coyote::Helpers::ProductionConfigHelper do
  subject = described_class

  describe "#redis_cache_config" do
    before do
      allow(Credentials).to receive(:dig).with(:cache, :redis_url).and_return(CRED_URL_VALUE)
    end

    it("fetches the redis url from ENV[\"#{ENV_URL_KEY}\"] if available") do
      ENV[ENV_URL_KEY] = ENV_URL_VALUE
      config = subject.redis_cache_config
      expect(config[:url]).to eq(ENV_URL_VALUE)
    end

    it("fetches the redis url from encrypted credentials if ENV[\"REDIS_CACHE_URL\"] is not present") do
      ENV.delete(ENV_URL_KEY)
      config = subject.redis_cache_config
      expect(config[:url]).to eq(CRED_URL_VALUE)
    end

    it("sets the namespace to \"staging\" if ENV[\"STAGING\"] is present") do
      ENV["STAGING"] = "1"
      config = subject.redis_cache_config
      expect(config[:namespace]).to eq("staging")
    end

    it("sets the namespace to \"production\" if ENV[\"STAGING\"] is not present") do
      ENV.delete("STAGING")
      config = subject.redis_cache_config
      expect(config[:namespace]).to eq("production")
    end
  end
end
