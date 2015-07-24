json.array!(@statuses) do |status|
  json.extract! status, :id, :title
  json.url status_url(status, format: :json)
end
