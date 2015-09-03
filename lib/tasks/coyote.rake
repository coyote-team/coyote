namespace :coyote do
  desc "Checks for new MCA images"
  task :update_mca => :environment do

    require 'multi_json'
    require 'open-uri'

    @website = Website.first
    limit = 1000
    offset = 0
    if Image.all.count > 10 #kludge
      updated_at = (Time.zone.now - 1.minute).iso8601
    else
      updated_at = nil
    end

    length = 1
    root = "https://cms.mcachicago.org"
    updated = 0
    created = 0
    errors = 0
    while length != 0 do
      #some images have a null updated at
      if updated_at
        url = root + "/api/v1/attachment_images?updated_at=#{updated_at}&offset=#{offset}&limit=#{limit}"
      else
        url = root + "/api/v1/attachment_images?offset=#{offset}&limit=#{limit}"
      end
      Rails.logger.info "grabbing images for #{url}"

      begin
        content = open(url, { "Content-Type" => "application/json", ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
      rescue OpenURI::HTTPError => error
        response = error.io
        Rails.logger.error response.string
        length = 0
      end
      begin
        images = JSON.parse(content)
      rescue Exception => e
        Rails.logger.error "JSON parsing exception"
        length = 0
      end

      length = images.length

      Rails.logger.info "length is #{length}"
      Rails.logger.info "Created: #{created}"
      Rails.logger.info "Updated: #{updated}"
      Rails.logger.info "Errors: #{errors}"
      Rails.logger.info "Total: #{errors + updated + created}"
      Rails.logger.info "Our total: #{@website.images.count}"


      images.each do |i|
        begin
          image = Image.find_or_create_by(canonical_id:  i["id"], website: @website)
          if image.new_record?
            image.website = @website
            group = Group.find_or_create_by(title: i["group"])
            group.save if group.new_record?
            image.group = group
            image.path = i["thumb_url"]
            image.created_at = i["created_at"]
            image.updated_at = i["updated_at"]
            image.save
            #create initial description field
            Rails.logger.info "created image #{image.id} from canonical id #{image.canonical_id}"
            created += 1
          else
            #update
            image.path = i["thumb_url"]
            image.updated_at = i["updated_at"]
            if image.save
              Rails.logger.info "updated image #{image.id} from canonical id #{image.canonical_id}"
              updated += 1
            else
              Rails.logger.error "save failed"
              errors += 1
            end
          end
          #create description if none are handy
          #if image.descriptions.length == 0  and !i["title"].blank?
            #d = Description.new(text: i["title"], locale: "en", metum_id: 2, image_id: image.id, status_id: 1, user_id: 1)
            #if d.save
              #Rails.logger.info "description #{d.id} for image #{image.id} saved"
            #else
              #Rails.logger.error "description save failed"
            #end
          #end

        rescue Exception => e
          Rails.logger.error "image creation error"
          Rails.logger.error i
          Rails.logger.error e
          errors += 1
        end
      end

      offset += limit
    end

    Rails.logger.info "--- Totals for #{Time.now} ---"
    Rails.logger.info "Created: #{created}"
    Rails.logger.info "Updated: #{updated}"
    Rails.logger.info "Errors: #{errors}"
    Rails.logger.info "Total: #{errors + updated + created}"
    Rails.logger.info "Our total: #{@website.images.count}"
    Rails.logger.info "---"

  end
end
