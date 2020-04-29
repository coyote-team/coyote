# frozen_string_literal: true

if defined? Google::Cloud::Storage
  Google::Cloud::Storage.configure do |config|
    config.project_id = Credentials.dig(:google, :project)
    config.credentials = Credentials.dig(:google, :cloud_keyfile)
  end
end
