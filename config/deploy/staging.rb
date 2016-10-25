set :stage, :staging
server ENV["STAGING_IP"], user: ENV["STAGING_USER"], roles: %w{web app db}
set :linked_files, %w{.env .env.staging} 
