if @images
  json._metadata do
    json.page @images.current_page
    json.pages @images.total_pages
    json.total_count @images.total_count
  end

  json.records  do
    json.array!(@images) do |image|
      json.extract! image, :id, :path, :group_id, :website_id
      json.url image_url(image, format: :json)
    end
  end
elsif @image
  json.partial! 'image', image: @image
end
