# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.ignore_hosts("selenium", "test", *Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host })
end

WebMock.disable_net_connect!(allow: [/validator/])
