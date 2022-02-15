# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "~> 6.0.1"

gem "acts_as_list"
gem "activerecord-postgres_enum"
gem "analytical" # analytics
gem "apipie-rails"
gem "audited"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", require: false
gem "faraday"
gem "ffi", require: false
gem "htmlentities"
gem "jsonapi-rails"
gem "jwt"
gem "kaminari"
gem "language_list"
gem "metamagic" # meta
gem "pg"
gem "pretender"
gem "puma"
gem "pundit"
gem "rake"
gem "ransack"
gem "redcarpet"
gem "redis-namespace"
gem "roo"
gem "safe-pg-migrations"
gem "sass-rails"
gem "sidekiq"
gem "simple_form"
gem "slim-rails"
gem "sprockets"
gem "sprockets-rails"
gem "tzinfo-data"
gem "webpacker"
gem "appsignal"

# Cloud storage options
gem "aws-sdk-s3", require: false # Comment this in to use S3 or Digital Ocean
# gem "google-cloud-storage", require: false # Comment this in to use Google Cloud Storage

group :development, :test do
  gem "factory_bot_rails", require: false
  gem "faker"
  gem "rspec-rails", ">= 3.6.1"
  gem "rubocop", require: false
  gem "rubocop-ordered_methods", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "standard", ">= 0.1.0", require: false
end

group :development do
  gem "annotate"
  gem "brakeman", require: false # basic security checks
  gem "federal_offense", ">= 0.1.2" # Trap and preview outbound emails
  gem "pry-rails" # debug with a Ruby REPL
  gem "rails_real_favicon" # manages many different favicons, apple touch icons, etc. see app/assets/images/favicon/manifest.json.erb
  gem "yard"

  unless ENV["TRAVIS"]
    # having a weird bundler/docker-compose issue on travis
    gem "guard", require: false
    gem "guard-brakeman", require: false
    gem "guard-bundler", require: false
    gem "guard-rspec", require: false
    gem "guard-rubocop", require: false
  end
end

group :test do
  gem "capybara", require: false
  gem "capybara-webmock", require: false
  gem "jsonapi-rspec", require: false
  gem "launchy", require: false #  to use save_and_open_page from Capybara
  gem "pundit-matchers", require: false # better rspec testing of policies
  gem "rails-controller-testing", require: false # so we can use render_template matcher in controller functional specs
  gem "selenium-webdriver", require: false
  gem "shoulda-matchers", require: false
  gem "simplecov", require: false
  gem "simplecov-material", require: false
  gem "vcr", require: false
  gem "webmock", require: false
  gem "webdrivers", require: false
end

# This hack is to ensure that Google's protocol buffers and GRPC libraries build correctly in
# Docker. It's the worst. I know it. I'm sorry. But otherwise we can't use Google libraries in
# Alpine.
module BundlerHack
  def __materialize__
    if name == "grpc" || name == "google-protobuf"
      Bundler.settings.temporary(force_ruby_platform: true) do
        super
      end
    else
      super
    end
  end
end

unless RUBY_PLATFORM.match?(/darwin|jruby|cygwin|mswin|mingw|bccwin|wince|emx/)
  Bundler::LazySpecification.prepend(BundlerHack)
end

group :production do
  gem "sentry-raven"
end
