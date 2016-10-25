Apipie.configure do |config|
  config.app_name                = "Coyote"
  config.api_base_url            = "/"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.app_info = <<-EOT
Image annotation site and API to enable the distributed annotation of museum images.  

All API endppoints expect either a json content type header or <code>.json</code> as an ending. You can find your user token in the regular site footer after you have logged in and then you can use either a request header like so:

    X-User-Email alice@example.com
    X-User-Token 1G8_s7P-V-4MGojaKD7a

Or a query string to authenticate:

   GET http://coyote.mcachicago.org/websites.json?user_token=1G8_s7P-V-4MGojaKD7a

When a description is approved for an image, a PATCH request is sent out to its resource URI.
  EOT
end
