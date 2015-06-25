json.array!(@descriptions) do |description|
  json.extract! description, :id, :locale, :text, :status_id, :image_id, :metum_id
  json.url description_url(description, format: :json)
end
