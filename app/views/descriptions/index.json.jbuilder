json._metadata do
  json.page @descriptions.current_page
  json.pages @descriptions.total_pages
  json.total_count @descriptions.total_count
end

json.records  do
  json.array!(@descriptions) do |description|
    json.extract! description, :id, :image_id, :status_id, :metum_id, :locale, :text, :user_id
    json.url description_url(description, format: :json)
  end
end

