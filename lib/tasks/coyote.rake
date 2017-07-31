namespace :coyote do
  namespace :admin do
    desc "Create an admin user"
    task :create, [:email,:password] => :environment do |_,args|
      password = args[:password]

      if password.blank?
        puts "Please enter a password for this user (minimum 8 characters):"
        password = STDIN.gets.chomp.upcase
      end

      user = User.create!(email: args[:email],password: password,admin: true)
      puts "Created #{user} (#{user.email}) with password '#{password}'"
    end
  end

  def import_tsv(headers,line)
    line = line.encode(line.encoding,universal_newline: true) # see https://stackoverflow.com/questions/1836046/normalizing-line-endings-in-ruby
    line.chomp!
    columns = line.split(/\t/)
    Hash[headers.zip(columns)]
  end

  namespace :db do
    desc "Import TSV files produced by mysqldump"
    task :import => :environment do
      # files produced with the command:
      #
      # mysqldump -u root --tab=/tmp coyote images
      # mysql2json --user=root --password= --database=coyote --execute "select * from images" > /tmp/images.json

      website_headers      = %i[id title url created_at updated_at strategy]
      context_headers      = %i[id title created_at updated_at]
      metum_headers        = %i[id title instructions created_at updated_at]
      status_headers       = %i[id title created_at updated_at]
      user_headers         = %i[id email encrypted_password reset_password_token reset_password_sent_at remember_created_at sign_in_count     current_sign_in_at last_sign_in_at  current_sign_in_ip last_sign_in_ip  created_at      updated_at     first_name    last_name    authentication_token   role]
      assignment_headers   = %i[id user_id image_id created_at updated_at]

      File.open("/tmp/meta.txt").each do |line|
        attribs = import_tsv(metum_headers,line)
        Metum.create!(attribs)
      end

      File.open("/tmp/statuses.txt").each do |line|
        attribs = import_tsv(status_headers,line)
        Status.create!(attribs)
      end

      File.open("/tmp/users.txt").each do |line|
        attribs = import_tsv(user_headers,line)
        attribs[:role] = "editor" # we'll adjust these later
        attribs[:password] = "password" # we'll bulk reset these later
        attribs.delete(:reset_password_token)

        User.create!(attribs)
      end

      File.open("/tmp/assignments.txt").each do |line|
        attribs = import_tsv(assignment_headers,line)

        begin
          attribs[:user] = User.find(attribs.delete(:user_id))
          attribs[:image] = Image.find(attribs.delete(:image_id))
        rescue ActiveRecord::RecordNotFound
          looks like there are some orphaned records
          next
        end

        Assignment.create!(attribs)
      end

      File.open("/tmp/websites.txt").each do |line|
        attribs = import_tsv(website_headers,line)
        strategy = attribs.delete(:strategy)

        if strategy =~ /MCA/
          strategy = "Coyote::Strategies::MCA"
        end

        attribs[:strategy] = strategy

        Website.create!(attribs)
      end

      File.open("/tmp/groups.txt").each do |line|
        attribs = import_tsv(context_headers,line)
        pp Context.create!(attribs)
      end

      File.open("/tmp/images.json") do |file|
        images = JSON.parse(file.read)

        images.each do |attribs|
          attribs.symbolize_keys!
          page_urls = attribs.delete(:page_urls)

          page_urls = if page_urls.present?
                        begin
                          JSON.parse(page_urls)
                        rescue
                          warn "unable to import page urls '#{page_urls}' for image ID #{attribs[:id]}"
                        end
                      else
                        nil
                      end

          attribs[:page_urls] = page_urls

          context_id = attribs.delete(:group_id)

          unless context_id =~ /^\d$/
            warn "cannot process image '#{attribs[:id]}' - missing data: #{context_id}"
            pp attribs
            puts "*" * 50
            next
          end

          begin
            attribs[:context] = Context.find(context_id)
          rescue
            warn "unable to import Image '#{attribs[:id]}' due to orphaned records (#{$!})"
            next
          end

          attribs[:priority] = !!attribs[:priority]

          Image.create!(attribs)
        end
      end

      File.open("/tmp/descriptions.json") do |file|
        descriptions = JSON.parse(file.read,symbolize_names: true)

        descriptions.each do |attribs|
          status_id = attribs.delete(:status_id)
          next if status_id.blank?

          image_id = attribs.delete(:image_id)
          next if image_id.blank?

          metum_id = attribs.delete(:metum_id)
          next if metum_id.blank?

          user_id = attribs.delete(:user_id)
          next if user_id.blank?

          begin
            attribs[:status] = Status.find(status_id)
            attribs[:image] = Image.find(image_id)
            attribs[:metum] = Metum.find(metum_id)
            attribs[:user] = User.find(user_id)
          rescue
            warn "unable to import description '#{attribs[:id]}' because of an orphaned record: #{$!}"
            pp attribs
            puts "*" * 50
            next
          end

          begin
            Description.create!(attribs)
          rescue
            pp attribs
            require "pry"; binding.pry
            warn "Could not import description '#{attribs[:id]}' due to invalid data (#{$!})"
            next
          end
        end
      end
    end

    desc "Create initial Context, Metum, and Status"
    task :start => :environment do
      Context.create!([
        { title: "collection" },
        { title: "website" },
        { title: "exhibitions" },
        { title: "events" },
      ])

      long_metum = <<~METUM
        A lengthier text than a traditional alt-text that attempts to provide a comprehensive representation of an image. 
        Long descriptions can range from one sentence to several paragraphs."
      METUM

      Metum.create!([
        { title: "Short", instructions: "A brief description enabling a user to interact with the image when it is not rendered or when the user has low vision" },
        { title: "Long",  instructions: long_metum }
      ])

      Status.create!([
        { title: "Ready to review" },
        { title: "Approved" },
        { title: "Not approved" }
      ])

      puts "Created Contexts, Metums, and Statuses"
    end
  end
end
