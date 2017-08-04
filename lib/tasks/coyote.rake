namespace :coyote do
  namespace :admin do
    desc "Create an admin user"
    task :create, [:email,:password] => :environment do |_,args|
      password = args[:password]

      if password.blank?
        puts "Please enter a password for this user (minimum 8 characters):"
        password = STDIN.gets.chomp.upcase
      end

      user = User.create!({
        :email => args[:email],
        :password => password,
        :role => :admin
      })

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
        attribs[:password] = "password"
        attribs.delete(:reset_password_token)

        User.create!(attribs)
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
        Context.create!(attribs)
      end

      contexts = Context.all.inject({}) { |t,c| t.merge(c.id => c) }
      statuses = Status.all.inject({}) { |t,c| t.merge(c.id => c) }
      meta = Metum.all.inject({}) { |t,c| t.merge(c.id => c) }
      users = User.all.inject({}) { |t,c| t.merge(c.id => c) }

      File.open("/tmp/images.json") do |file|
        images = JSON.parse(file.read,symbolize_names: true)

        images.in_groups_of(1000,false) do |group|
          group.map! do |attribs|
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

            attribs[:context] = contexts.fetch(context_id.to_i) do
              warn "unable to import Image '#{attribs[:id]}' due to orphaned records (#{$!})"
              next
            end

            attribs[:priority] = !!attribs[:priority]
            attribs
          end

          group.compact!
          images = Image.create!(group)

          puts "Imported #{images.count}"
        end
      end

      images = Image.all.inject({}) { |t,c| t.merge(c.id => c) }
      
      File.open("/tmp/assignments.txt").each do |line|
        attribs = import_tsv(assignment_headers,line)

        user_id = attribs.delete(:user_id)
        image_id = attribs.delete(:image_id)

        attribs[:user] = users.fetch(user_id.to_i) do
          warn "Unable to import assignment #{attribs[:id]}: missing user"
          next
        end

        attribs[:image] = images.fetch(image_id.to_i) do
          warn "Unable to import assignment #{attribs[:id]}: missing image"
          next
        end

        Assignment.create!(attribs)
      end

      File.open("/tmp/descriptions.json") do |file|
        descriptions = JSON.parse(file.read,symbolize_names: true)

        descriptions.in_groups_of(1000,false).each do |group|
          group.map! do |attribs|
            status_id = attribs.delete(:status_id).to_i
            image_id = attribs.delete(:image_id).to_i
            metum_id = attribs.delete(:metum_id).to_i
            user_id = attribs.delete(:user_id).to_i

            attribs[:status] = statuses.fetch(status_id) do
              warn "unable to import description '#{attribs[:id]}' because of bad status: #{status_id}"
              next
            end

            attribs[:image] = images.fetch(image_id) do
              warn "unable to import description '#{attribs[:id]}' because of bad image ID: #{image_id}"
              next
            end

            attribs[:metum] = meta.fetch(metum_id) do
              warn "unable to import description '#{attribs[:id]}' because of bad metum_id: #{metum_id}"
              next
            end

            attribs[:user] = users.fetch(user_id) do
              warn "unable to import description '#{attribs[:id]}' because of bad status: #{user_id}"
              next
            end

            attribs
          end

          desc = Description.create!(group)
          puts "Created #{desc.count} descriptions"
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
