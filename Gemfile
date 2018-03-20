# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# TEMPORARILY INSTALLING THIS TO FACILITATE MIGRATING FROM MYSQL
# TODO: remove this dependency after migration is complete
gem 'mysql2', require: false

gem 'rails', '5.1.3'

gem 'analytical' # analytics
gem 'apipie-rails'
gem 'audited'
gem 'autoprefixer-rails'
gem 'bootstrap-sass', '3.3.7'
gem 'compass-rails' # TODO: Remove
gem 'compass-h5bp' # TODO: Remove
gem 'devise' # user auth
gem 'dotenv-rails'
gem 'easymarklet', git: 'https://github.com/seeread/easymarklet.git', ref: '53829a6'
gem 'factory_girl_rails', require: false
gem 'haml-rails', '>= 1.0.0'
gem 'high_voltage' # static pages
gem 'iconv'
gem 'jquery-rails', '>= 4.0.4'
gem 'jsonapi-rails'
gem 'kaminari'
gem 'language_list'
gem 'lightbox2-rails', github: 'johansmitsnl/lightbox2-rails' # for resource lightboxes on index pages
gem 'markdown-rails'
gem 'metamagic' # meta
gem 'modular-scale', require: false
gem 'pg', '~> 0.20.0' # our version of activerecord has a bug with v0.21; see https://stackoverflow.com/questions/44607324/installing-newest-version-of-rails-4-with-postgres-the-pgconn-pgresult-and-p
gem 'puma'
gem 'pundit' # role-based authorization
gem 'ransack'
gem 'redcarpet'
gem 'rollbar'
gem 'sass-mediaqueries-rails' # TODO: Remove
gem 'sass-rails'
gem 'simple_form' # , git: 'https://github.com/plataformatec/simple_form.git'
gem 'sprockets'
gem 'sprockets-rails'
gem 'uglifier', '>= 2.7.1' # js compression

group :development, :test do
  gem 'faker'
  gem 'rspec-rails', '>= 3.6.1'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'         # optional dependency of better_errors
  gem 'brakeman', require: false  # basic security checks
  gem 'pry-rails'                 # gives us binding.pry calls
  gem 'rails_real_favicon'        # manages many different favicons, apple touch icons, etc. see app/assets/images/favicon/manifest.json.erb
  gem 'spring'
  gem 'yard'

  unless ENV["TRAVIS"]
    # having a weird bundler/docker-compose issue on travis
    gem 'guard', require: false
    gem 'guard-brakeman', require: false
    gem 'guard-bundler', require: false
    gem 'guard-coffeescript', require: false
    gem 'guard-livereload', require: false
    gem 'guard-rspec', require: false
    gem 'guard-rubocop', require: false
    gem 'guard-sass', require: false
    gem 'rb-fsevent' # osx file system changes
  end
end

group :test do
  gem 'airborne'
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'jsonapi-rspec'
  gem 'launchy' #  to use save_and_open_page from Capybara
  gem 'pundit-matchers' # better rspec testing of policies
  gem 'rails-controller-testing' # so we can use render_template matcher in controller functional specs
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'vcr'
  gem 'webmock'
end

group :production do
  gem 'rails_12factor'
end
