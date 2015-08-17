set :stage, :production
server '104.154.48.143', user: 'seeread', roles: %w{web app db}
set :linked_files, %w{.env .env.production} #TODO make this smarter
