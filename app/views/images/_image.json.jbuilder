json.extract! image, :id, :canonical_id, :path, :group_id, :website_id, :created_at, :updated_at 

json.url image_url(@image, format: 'html')
json.alt image.alt(@status_ids)
json.long image.long(@status_ids)

if !@status_ids.empty?
  descriptions = image.descriptions.where(status_id: @status_ids)
else
  descriptions = image.descriptions
end
json.descriptions descriptions  do |description|
  json.partial! "descriptions/description", description: description
end
