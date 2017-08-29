json.array!(@users) do |user|
  json.extract! user, :id, :first_name, :last_name, :email, :admin
  json.url organization_user_url(current_organization,user, format: :json)
end
