# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")

# Precompile additional assets.
Rails.application.config.assets.precompile += %w[application.js]
Rails.application.config.assets.precompile += %w[coyote_bookmarklet.js coyote_bookmarklet.css coyote_consumer.js coyote_producer.js]
Rails.application.config.assets.precompile += %w[favicon/browserconfig.xml favicon/manifest.json]
# Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
