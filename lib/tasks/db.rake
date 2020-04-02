# frozen_string_literal: true

namespace :db do
  desc "Migrate the database, or set it up if we haven't already"
  task migrate_or_setup: :environment do
    # If the database is set up, migrate it
    version = ActiveRecord::Base.connection.select_value("SELECT version FROM schema_migrations LIMIT 1")
    raise StandardError.new("Needs database setup") if version.blank?

    Rake::Task["db:migrate"].invoke
  rescue
    # If the database is not set up, do so now
    Rake::Task["db:create"].invoke
    Rake::Task["db:structure:load"].invoke
  end
end
