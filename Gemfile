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
gem "aws-sdk-s3", require: false
gem "bootsnap"
gem "devise" # user auth
gem "easymarklet", git: "https://github.com/seeread/easymarklet.git", ref: "53829a6"
gem "haml-rails", ">= 1.0.0"
gem "iconv"
gem "jquery-rails", ">= 4.0.4"
gem "jsonapi-rails"
gem "kaminari"
gem "language_list"
gem "lightbox2-rails", github: "johansmitsnl/lightbox2-rails" # for resource lightboxes on index pages
gem "metamagic" # meta
gem "mini_racer", require: false
gem "pg", "~> 0.20.0" # our version of activerecord has a bug with v0.21; see https://stackoverflow.com/questions/44607324/installing-newest-version-of-rails-4-with-postgres-the-pgconn-pgresult-and-p
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
  gem "figaro", "1.0"
  gem "pry-rails" # gives us binding.pry calls
  gem "rails_real_favicon" # manages many different favicons, apple touch icons, etc. see app/assets/images/favicon/manifest.json.erb
  gem "yard"

  unless ENV["TRAVIS"]
    # having a weird bundler/docker-compose issue on travis
    gem "guard", require: false
    gem "guard-brakeman", require: false
    gem "guard-bundler", require: false
    gem "guard-coffeescript", require: false
    gem "guard-livereload", require: false
    gem "guard-rspec", require: false
    gem "guard-rubocop", require: false
    gem "guard-sass", require: false
    gem "rb-fsevent" # osx file system changes
  end
end

group :test do
  gem "airborne"
  gem "capybara"
  gem "codeclimate-test-reporter", require: nil
  gem "database_cleaner"
  gem "jsonapi-rspec"
  gem "launchy" #  to use save_and_open_page from Capybara
  gem "pundit-matchers" # better rspec testing of policies
  gem "rails-controller-testing" # so we can use render_template matcher in controller functional specs
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "vcr"
  gem "webmock"
end

group :production do
  gem "google-cloud-storage"
  gem "sentry-raven"
end

# NOTE: Comment this back in if you need to reactivate Scavenger Hunt
# gem "scavenger_hunt", path: "lib/scavenger_hunt"
