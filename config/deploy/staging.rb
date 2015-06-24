set :stage, :staging
server '54.68.6.95', user: 'ubuntu', roles: %w{web app db}
# namespace :deploy do
#   before :restart, "deploy:sitemap:clean"
#   after :restart, "deploy:sitemap:refresh" #Create sitemaps and ping search engines
# end
