namespace :coyote do
  namespace :admin do
    desc "Create an admin user"
    task :create, [:email] => :environment do |_,args|
      puts "Please enter a password for this user (minimum 8 characters):"
      password = STDIN.gets.chomp.upcase

      user = User.create!(email: args[:email],password: password)
      puts "Created #{user} (#{user.email})"
    end
  end
end
