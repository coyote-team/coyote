namespace :backup do
  desc "Backup database"
  task :db do
    app_root = File.join(File.dirname(__FILE__), "..", "..")
    output_file = File.join(app_root, "..", "#{ENV['DATABASE_NAME']}-#{Time.now.strftime('%Y%m%d')}.sql")
    if ENV['DATABASE_PASSWORD'] and !ENV['DATABASE_PASSWORD'].blank?
      command = "/usr/bin/env mysqldump -h #{ENV['DATABASE_HOST']} -u #{ENV['DATABASE_USERNAME']} -p#{ENV['DATABASE_PASSWORD']} #{ENV['DATABASE_NAME']} > #{output_file}"
    else
      command = "/usr/bin/env mysqldump -h #{ENV['DATABASE_HOST']} -u #{ENV['DATABASE_USERNAME']} #{ENV['DATABASE_NAME']} > #{output_file}"
    end
    puts command
    system(command)
  end
end
