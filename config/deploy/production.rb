set :stage, :production
server 'coyote.mcachicago.org', user: 'seeread', roles: %w{web app db}
set :linked_files, %w{.env .env.production} #TODO make this smarter
