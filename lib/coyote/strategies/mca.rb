class MCAStrategy < Strategy

  #title
  #patch
  #update
  #check_count
  #update_bulk

  def title
    "MCA"
  end

  #returns true
  def patch(image)
    website = image.website
    if image.status_code >= 2 and Rails.env.production?
      url = website.url + "/api/v1/attachment_images/" + image.canonical_id
      url = URI.parse(url)
      req = Net::HTTP::Patch.new(url)
      res = Net::HTTP.start(url.host, url.port,   :use_ssl => url.scheme == 'https',  :verify_mode => OpenSSL::SSL::VERIFY_NONE) {|http|
          http.request(req)
      }
      Rails.logger.info "Patched to #{url.to_s}"
    end
    return true
  end

  #returns true 
  #http://mcachicago.org/api/v1/attachment_images.json?updated_at=2016-10-20T20:41:40Z&offset=0&limit=100
  def update(website, minutes_ago)
    require 'multi_json'
    require 'open-uri'

    limit = 100
    offset = 0
    updated_at = (Time.zone.now - minutes_ago.to_f.minute).iso8601
    updated_at = nil if Image.all.count < 10 #kludge for seeding

    length = 1
    root = website.url
    updated = 0
    created = 0
    errors = 0
    images = {}
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

      Rails.logger.info "Array length is #{length}"
      Rails.logger.info "Created: #{created}"
      Rails.logger.info "Updated: #{updated}"
      Rails.logger.info "Errors: #{errors}"
      Rails.logger.info "Total: #{errors + updated + created}"
      Rails.logger.info "Our total: #{website.images.count}"

      images.each do |i|
        begin
          image = Image.find_or_create_by(canonical_id:  i["id"], website: website)
          if image.new_record?
            image.website = website
            group = Group.find_or_create_by(title: i["group"])
            group.save if group.new_record?
            image.group = group
            image.path = i["thumb_url"]
            image.created_at = i["created_at"]
            image.updated_at = i["updated_at"]
            image.title = i["title"]
            image.page_urls = i["page_urls"]
            image.save
            #create initial description field
            Rails.logger.info "created image #{image.id} from canonical id #{image.canonical_id}"
            created += 1
          else
            #update
            image.title = i["title"]
            image.path = i["thumb_url"]
            image.page_urls = i["page_urls"]
            image.updated_at = i["updated_at"]
            if image.save
              Rails.logger.info "updated image #{image.id} from canonical id #{image.canonical_id}"
              updated += 1
            else
              Rails.logger.error "save failed"
              errors += 1
            end
          end

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
    Rails.logger.info "Our total: #{website.images.count}"
    Rails.logger.info "---"
    return true
  end

  #returns array of canonical ids
  def check_count(website)
    require 'multi_json'
    require 'open-uri'

    ids = []
    limit = 200
    offset = 0
    length = 1
    while length != 0 do
      url = "#{website.url}/api/v1/attachment_images?offset=#{offset}&limit=#{limit}"
      Rails.logger.info "getting ids from #{url}"

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
        Rails.logger.error e
        length = 0
      end

      Rails.logger.info "count of images here is: #{images.count}"
      ids.push images.collect{|i| i["id"]}

      if images and images.length
        length = images.length
        offset += limit
      else
        length = 0
      end
    end

    ids.flatten!
    ids.compact!
    return ids.uniq
  end

  #optional
  #returns true
  def patch_bulk(website, minutes_ago)
    updated_at = (Time.zone.now - minutes_ago.to_f.minute).iso8601
    images = Description.where("updated_at > ?", updated_at).collect{|d| d.image if d.image.status_code >= 2 and d.image.website == website}.compact.uniq
    Rails.logger.info "These images are ready to be updated for #{images.collect{|i| i.id}.join(", ")}"
    images.each{|i| patch(i)}
    return true
  end
end
