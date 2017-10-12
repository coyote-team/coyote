# Needed to make JSONAPI serializers work; unfortunately it doesn't work if we set this as configuration parameter inside config/application.rb
Rails.application.routes.default_url_options = { host: Rails.configuration.x.host_name }
