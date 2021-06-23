# frozen_string_literal: true

namespace :db do
  desc "Migrate the database, or set it up if we haven't already"
  task migrate_or_setup: :environment do
    migrate = true
    version = ActiveRecord::Base.connection.select_value("SELECT version FROM schema_migrations LIMIT 1")
    raise StandardError.new("Needs database setup") if version.blank?
    Rails.logger.warn "Preparing to run migrations..."
  rescue => error
    Rails.logger.warn "Cannot run migrations. Trying setup instead: #{error.inspect}"
    migrate = false
  ensure
    if migrate
      # If the database is set up, migrate it
      Rake::Task["db:migrate"].invoke
    else
      # If the database is not set up, do so now
      Rake::Task["db:create"].invoke
      Rake::Task["db:structure:load"].invoke
    end
  end
end
