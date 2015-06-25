json.array!(@images) do |image|
  json.extract! image, :id, :url, :website_id
  json.url image_url(image, format: :json)
end
