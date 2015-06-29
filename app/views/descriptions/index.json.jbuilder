json.array!(@descriptions) do |description|
  json.extract! description, :id, :image_id, :status_id, :metum_id, :locale, :text
  json.url description_url(description, format: :json)
end
