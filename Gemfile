# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "~> 6.0.1"

gem "analytical" # analytics
gem "apipie-rails"
gem "audited"
gem "autoprefixer-rails"
# gem "aws-sdk-s3", require: false # Comment this in to use S3 instead of Google Cloud Storage - see config/storage.yml
gem "bootsnap", require: false
gem "cloudtasker"
gem "devise" # user auth
gem "easymarklet", git: "https://github.com/seeread/easymarklet.git", ref: "53829a6"
gem "faraday"
gem "haml-rails", ">= 1.0.0"
gem "jquery-rails", ">= 4.0.4"
gem "jsonapi-rails"
gem "kaminari"
gem "language_list"
gem "lightbox2-rails", github: "johansmitsnl/lightbox2-rails" # for resource lightboxes on index pages
gem "metamagic" # meta
gem "mini_racer", require: false
gem "pg"
gem "puma"
gem "pundit"
gem "rake"
gem "ransack"
gem "redcarpet"
gem "sass-rails"
gem "simple_form"
gem "slim-rails"
gem "sprockets"
gem "sprockets-rails"
gem "uglifier", ">= 2.7.1" # js compression
gem "vanilla-ujs"

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
  gem "pry-rails" # gives us binding.pry calls
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
  gem "database_cleaner", require: false
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

Bundler::LazySpecification.prepend(BundlerHack)

group :production do
  gem "google-cloud-storage", require: false
  gem "google-protobuf", "3.12.0.rc.1", platforms: ["ruby"]
  gem "grpc", "1.27.0", platforms: ["ruby"]
  gem "sentry-raven"
end

# NOTE: Comment this back in if you need to reactivate Scavenger Hunt
# gem "scavenger_hunt", path: "lib/scavenger_hunt"
