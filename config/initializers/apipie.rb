# frozen_string_literal: true

Apipie.configure do |config|
  config.app_name = "Coyote"
  config.api_base_url = "/"
  config.doc_base_url = "/apidoc"
  config.validate = :explicitly
  config.api_controllers_matcher = Rails.root.join("app", "controllers", "api", "**", "*.rb").to_s
  config.app_info = <<~EOT
    {JSON API}[http://jsonapi.org/] for {Coyote}[https://coyote-team.github.io/coyote/].

    Accessing the API requires use of the authorization token that appears at the bottom of Coyote pages for logged-in users. Example:
    curl  -H 'Authorization: CHANGEME' http://localhost:10000/api/v1/organizations/1/resources | jsonlint
  EOT

  # see https://github.com/Apipie/apipie-rails/issues/549
  config.translate = false
  config.default_locale = :en
end
