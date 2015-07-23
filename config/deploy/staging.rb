set :stage, :staging
server '', user: 'ubuntu', roles: %w{web app db}
set :linked_files, %w{.env .env.staging} 
