# frozen_string_literal: true

# Be sure to restart your server when you modify this file

# Version of your assets, change this if you want to expire all your assets
assets = Rails.application.config.assets
assets.version = "1.0"

# Precompile additional assets
# assets.paths << Rails.root.join("node_modules")
assets.precompile += %w[application.css]
assets.precompile += %w[favicon/browserconfig.xml favicon/manifest.json]
