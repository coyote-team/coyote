Apipie.configure do |config|
  config.app_name                = "Coyote"
  config.api_base_url            = "/"
  config.doc_base_url            = "/apipie"
  config.validate = :explicitly
  config.api_controllers_matcher = "#{Rails.root}/app/api/controllers/**/*.rb"
  config.app_info = <<~EOT
  Resource annotation site and API
  EOT
end
