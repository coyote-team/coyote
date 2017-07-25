namespace :coyote do
  namespace :admin do
    desc "Create an admin user"
    task :create, [:email,:password] => :environment do |_,args|
      password = args[:password]

      if password.blank?
        puts "Please enter a password for this user (minimum 8 characters):"
        password = STDIN.gets.chomp.upcase
      end

      user = User.create!(email: args[:email],password: password)
      puts "Created #{user} (#{user.email}) with password '#{password}'"
    end
  end

  namespace :db do
    desc "Create initial Group, Metum, and Status"
    task :start => :environment do
      Group.create!([
        { title: "collection" },
        { title: "website" },
        { title: "exhibitions" },
        { title: "events" },
      ])

      Metum.create!([
        { title: "Short", instructions: "A brief description enabling a user to interact with the image when it is not rendered or when the user has low vision" },
        { title: "Long",  instructions: "A lengthier text than a traditional alt-text that attempts to provide a comprehensive representation of an image. Long descriptions can range from one sentence to several paragraphs." }
      ])

      Status.create!([
        { title: "Ready to review" },
        { title: "Approved" },
        { title: "Not approved" }
      ])

      puts "Created Groups, Metums, and Statuses"
    end
  end
end
