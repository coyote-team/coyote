set :stage, :production
server ENV["PRODUCTION_IP"], user: ENV["PRODUCTION_USER"], roles: %w{web app db}
set :linked_files, %w{.env .env.production} 
