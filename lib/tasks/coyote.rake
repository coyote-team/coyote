namespace :coyote do
  desc "Checks for new MCA images"
  task :update_mca do

    require 'multi_json'
    require 'open-uri'

    limit = 1000
    offset = 0
    if Image.count > 10 #kludge
      updated_at = (Time.zone.now - 30.seconds).iso8601
    else
      updated_at = (Time.zone.now - 100.years).iso8601
    end

    length = 1 
    root = "https://cms.mcachicago.org"
    while length != 0 do
      url = root + "/api/v1/attachment_images?updated_at=#{updated_at}&offset=#{offset}&limit=#{limit}"
      puts "grabbing images for #{url}"

      begin
        content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
      rescue OpenURI::HTTPError => error
        response = error.io
        puts response.string
        length = 0
      end

      begin 
        images = JSON.parse(content)
      rescue Exception => e
        puts "JSON parsing exception"
        length = 0
      end

      length = images.length 

      images.each do |i|
        begin 
          image = Image.find_or_create_by(canonical_id:  i["id"])
          if image.new_record?
            image.website = Website.first
            group = Group.find_or_create_by(title: i["group"])
            group.save if group.new_record?
            image.group = group
            image.path = i["thumb_url"]
            image.created_at = i["created_at"]
            image.updated_at = i["updated_at"]
            image.save
            #create initial description field
            puts "created image #{image.id} from canonical id #{image.canonical_id}"
          else
            image.path = i["thumb_url"]
            image.updated_at = i["updated_at"]
            image.save
            puts "updated image #{image.id} from canonical id #{image.canonical_id}"
          end
          #update descriptions?
        rescue Exception => e
          puts "image creation error"
          puts i
          puts e
        end
      end

      offset += limit
    end

  end
end
