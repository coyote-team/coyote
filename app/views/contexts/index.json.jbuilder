json.array!(contexts) do |context|
  json.extract! context, :id, :title
  json.url context_url(context, format: :json)
end
