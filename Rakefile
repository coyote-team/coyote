# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

#do not drop prod db
namespace :db do
    #task :drop => :abort_on_production
end
task :abort_on_production do
    abort "Don't drop production database. aborted. " if Rails.env.production?
end

Plate::Application.load_tasks
