json.array!(@meta) do |metum|
  json.extract! metum, :id, :title, :instructions
  json.url metum_url(metum, format: :json)
end
