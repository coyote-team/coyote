json.extract! @image, :id, :canonical_id, :path, :group_id, :website_id, :created_at, :updated_at
json.descriptions @image.descriptions do |description|
  json.partial! "descriptions/description", description: description
end
