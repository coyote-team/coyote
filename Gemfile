source 'https://rubygems.org'
gem 'dotenv-rails'
gem 'rails', '4.2.5.1'
gem 'language_list'
gem 'iso639-validator'
gem 'sass-rails', '~> 5.0.1' #sass and sprockets upgrades can be delicate 
gem 'compass-rails', '~> 3.0.2'
gem 'bootstrap-sass', '>= 3.2'
gem 'sprockets'
gem "lograge"
#gem "sprockets-redirect"
gem 'sprockets-rails', '~> 3.0.3'
gem 'autoprefixer-rails'
gem 'compass-h5bp'
gem 'modular-scale'
gem 'sass-mediaqueries-rails'
gem 'mysql2', '~> 0.3.18'
gem 'seed_dump'
gem 'actionpack-action_caching' #caching
gem 'annotate'
gem 'kaminari'
gem 'ransack'
gem 'simple_form', :git=>'https://github.com/plataformatec/simple_form.git'  #forms
gem 'devise' #user auth
gem 'acts-as-taggable-on' #automplete tags
gem "select2-rails", git: 'https://github.com/argerim/select2-rails.git'
gem 'cocoon' #nested forms
gem 'analytical' #analytics
gem 'metamagic' #meta
gem 'browser' #browser detection
gem "therubyracer" #node for compiling js
gem 'oj' #optimized json
gem "thin", ">= 1.6.3" # webserver
gem 'turbolinks' #crazy fake ajax
gem 'responders' #respond_with ala  http://www.justinweiss.com/blog/2014/11/03/respond-to-without-all-the-pain/
gem 'redcarpet'
gem 'html2markdown'
gem 'markdown-rails'
gem 'high_voltage' #static pages
gem 'coffee-rails', '>= 4.1.0'
gem 'jquery-rails', ">= 4.0.4"
gem 'execjs' 
gem 'uglifier', '>= 2.7.1' #js compression
gem "validate_url"
gem 'tilt' #template interface
gem "haml-rails"
gem 'whenever'
gem 'apipie-rails'
gem 'simple_token_authentication' #token auth for api
gem 'jbuilder' #json builder
gem 'roo' #spreadsheet interfaces
gem 'iconv'
gem "audited-activerecord"
gem 'easymarklet', :git=>'https://github.com/seeread/easymarklet.git', :ref => '53829a6'

gem 'rollbar', '~>2.11.3'

group :development do
  gem "better_errors"
  gem "html2haml"
  gem "binding_of_caller"
  gem "quiet_assets"
  gem 'rails_real_favicon'
  gem 'brakeman', :require => false
  gem 'spring'
  gem 'guard'
  gem 'guard-cucumber'
  gem 'guard-brakeman'
  gem 'guard-bundler'
  gem 'guard-coffeescript'
  gem 'guard-sass'
  gem 'guard-livereload'
  gem 'capistrano', '>= 3.2.1' #deployment.  also delicate
  gem 'capistrano-nc', '>= 0.1.3'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv', '>= 2.0'
  gem 'capistrano-thin'
  gem 'capistrano-flowdock'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  gem 'rb-fsevent' #osx file system changes
  gem 'factory_girl_rails', require: false
  gem 'faker'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem 'shoulda-matchers'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'webmock'
  gem 'selenium-webdriver'
  gem 'capybara-accessible'
  gem 'be_valid_asset'
  gem 'mortise', :git=>'https://github.com/seeread/mortise.git' #tenon
  gem 'airborne'
end
