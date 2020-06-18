# frozen_string_literal: true

# Be sure to restart your server when you modify this file

require "static_html_renderer"

# Version of your assets, change this if you want to expire all your assets
assets = Rails.application.config.assets
assets.version = "1.0"

# Add additional assets to the asset load path
assets.paths << Rails.root.join("node_modules")
assets.paths << Rails.root.join("app", "assets", "html")

# Add support for Slim rendering of HTML files
assets.configure do |env|
  env.register_mime_type "text/slim", extensions: [".html.slim"]
  env.register_transformer "text/slim", "text/html", StaticHTMLRenderer
end

# Precompile additional assets
assets.precompile += %w[application.css application.js]
assets.precompile += %w[coyote_bookmarklet.js coyote_bookmarklet.css coyote_consumer.js coyote_producer.js]
assets.precompile += %w[favicon/browserconfig.xml favicon/manifest.json]
assets.precompile += %w[**/*.html]

# Prevent fingerprinting of generated HTML files, since they're used to render errors in production
NonDigestAssets.whitelist += [%r{.+\.html$}] if defined? NonDigestAssets
