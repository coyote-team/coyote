#TODO move description look up into controller
json.extract! image, 
  :id, 
  :canonical_id, 
  :path, 
  :page_urls, 
  :priority, 
  :group_id, 
  :website_id, 
  :created_at, 
  :updated_at 

json.url image_url(image, format: 'html')
json.alt image.alt(@status_ids)
json.title image.title
json.long image.long(@status_ids)

descriptions = image.descriptions.where(status_id: @status_ids)
json.descriptions descriptions  do |description|
  json.partial! "descriptions/description", description: description
end
