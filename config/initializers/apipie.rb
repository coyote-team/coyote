Apipie.configure do |config|
  config.app_name                = "Coyote"
  config.api_base_url            = "/"
  config.doc_base_url            = "/apidoc"
  config.validate = :explicitly
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.app_info = <<~EOT
  Resource annotation site and API
  EOT

  # see https://github.com/Apipie/apipie-rails/issues/549
  config.translate = false
  config.default_locale = :en
end
