json.extract! image, :id, :canonical_id, :alt, :caption, :long, :path, :group_id, :website_id, :created_at, :updated_at 

if !@status_ids.empty?
  descriptions = image.descriptions.where(status_id: @status_ids)
else
  descriptions = image.descriptions
end
json.descriptions descriptions  do |description|
  json.partial! "descriptions/description", description: description
end
