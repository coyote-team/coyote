json.array!(@websites) do |website|
  json.extract! website, :id, :title, :url
  json.url website_url(website, format: :json)
end
