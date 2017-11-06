namespace :dev_only do
  task :check_env do
    environments = %w[test development]
    abort "Cannot run this command in any environments except #{environments.to_sentence}" unless environments.include?(Rails.env)
  end

  desc 'terminate connections to development and test database'
  task disconnect: %i[environment check_env] do
    db_name = ActiveRecord::Base.configurations.fetch(Rails.env).fetch('database')

    puts "Terminating connections to '#{db_name}'"

    ActiveRecord::Base.connection.execute <<~SQL
      SELECT pg_terminate_backend(pg_stat_activity.pid)
      FROM pg_stat_activity
      WHERE pg_stat_activity.datname = '#{db_name}'
      AND pid <> pg_backend_pid();
    SQL
  end

  desc "Truncate the development database"
  task truncate: %i[environment check_env] do
    require 'database_cleaner'
    puts "Truncating #{Rails.env} database..."
    DatabaseCleaner.clean_with(:truncation,except: %w[ar_internal_metadata])
  end

  desc 'Truncate the development database and replace with new seed data'
  task reseed: %i[truncate db:seed]
end
