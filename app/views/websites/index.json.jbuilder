json.array!(websites) do |website|
  json.extract! website, :id, :title, :url
  json.resource_url organization_website_url(current_organization,website, format: :json)
end
