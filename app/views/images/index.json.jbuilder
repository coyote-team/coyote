json.array!(@images) do |image|
  json.extract! image, :id, :path, :group_id, :website_id
  json.url image_url(image, format: :json)
end
