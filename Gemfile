# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.4.1'

gem 'dotenv-rails'
gem 'rails', '5.1.3'
gem 'language_list'
gem 'iso639-validator'
gem 'sass-rails', '~> 5.0.1' # sass and sprockets upgrades can be delicate
gem 'compass-rails', '~> 3.0.2'
gem 'bootstrap-sass', '>= 3.2'
gem 'sprockets'
gem 'lograge'
gem 'sprockets-rails', '~> 3.0.3'
gem 'autoprefixer-rails'
gem 'compass-h5bp'
gem 'modular-scale'
gem 'sass-mediaqueries-rails'
gem 'pg', '~> 0.20.0' # our version of activerecord has a bug with v0.21; see https://stackoverflow.com/questions/44607324/installing-newest-version-of-rails-4-with-postgres-the-pgconn-pgresult-and-p 
gem 'kaminari'
gem 'ransack'
gem 'simple_form' # , git: 'https://github.com/plataformatec/simple_form.git'
gem 'devise' # user auth
gem 'acts-as-taggable-on' # automplete tags
gem 'select2-rails', git: 'https://github.com/argerim/select2-rails.git'
gem 'cocoon' # nested forms
gem 'analytical' # analytics
gem 'metamagic' # meta
gem 'oj' # optimized json
gem 'puma'
gem 'turbolinks' # crazy fake ajax
gem 'responders' # respond_with ala  http://www.justinweiss.com/blog/2014/11/03/respond-to-without-all-the-pain/
gem 'redcarpet'
gem 'markdown-rails'
gem 'high_voltage' # static pages
gem 'coffee-rails', '>= 4.1.0'
gem 'jquery-rails', '>= 4.0.4'
gem 'execjs' 
gem 'uglifier', '>= 2.7.1' # js compression
gem 'validate_url'
gem 'tilt' # template interface
gem 'haml-rails', '>= 1.0.0'
gem 'whenever'
gem 'apipie-rails'
gem 'simple_token_authentication' # token auth for api
gem 'jbuilder' # json builder
gem 'roo' # spreadsheet interfaces
gem 'iconv'
gem 'audited'
gem 'easymarklet', git: 'https://github.com/seeread/easymarklet.git', ref: '53829a6'
gem 'rollbar', '~>2.11.3'
gem 'factory_girl_rails', require: false

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  gem 'rb-fsevent' # osx file system changes
  gem 'faker'
end

group :development do
  gem 'better_errors'
  gem 'html2haml'
  gem 'binding_of_caller'
  gem 'rails_real_favicon'
  gem 'brakeman', :require => false
  gem 'spring'
  gem 'guard'
  gem 'guard-brakeman'
  gem 'guard-bundler'
  gem 'guard-coffeescript'
  gem 'guard-sass'
  gem 'guard-livereload'
  gem 'yard'
  gem 'annotate'
  gem 'guard-rubocop'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'webmock'
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'airborne'
  gem 'launchy' #  to use save_and_open_page from Capybara
  gem 'vcr'
end

group :production do
  gem 'rails_12factor'
end
