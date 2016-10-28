set :application,  ENV['REPO_NAME']
set :repo_url,   ENV['REPO_URL']

set :scm, :git
set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :flowdock_project_name, ENV['FLOWDOCK_PROJECT_NAME']
set :flowdock_deploy_tags, ["deploy"]
set :flowdock_api_token, ENV['FLOWDOCK_API_TOKEN']

set :user, ENV["SERVER_USER"]
set :deploy_to, "/home/#{fetch(:user)}/data/#{fetch(:application)}"
set :ssh_options, { :forward_agent => true, 
                    :keys => %w(~/.ssh/id_rsa),
                    :auth_methods => %w(publickey)}

set :keep_releases, 5

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}

namespace :deploy do
  before :restart, "assets:precompile"
  after :publishing, :restart
  #before :restart, "deploy:sitemap:clean"
  #after :restart, "deploy:sitemap:refresh" #Create sitemaps and ping search engines
  after :restart, :clear_cache do
    on roles(:web), limit: 1 do
      within release_path do
        execute :rake, "cache:clear RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end
end
namespace :dotenv do
  desc "Env config"
  task :upload do
    on roles(:all) do
      fetch(:linked_files).each do |file|
        upload! file, "#{shared_path}/#{file}"
      end
    end
  end
  before 'deploy:check:linked_files', 'dotenv:upload'
end

namespace :thin do
  commands = [:start, :stop, :restart]
  commands.each do |command|
    desc "thin #{command}"
    task command do
      on roles(:app), in: :sequence, wait: 5 do
        within current_path do
          config_file = fetch(:thin_config_path, "config/thin/#{fetch(:stage)}.yml")
          execute :bundle, "exec thin #{command} -c /home/#{fetch(:user)}/data/#{fetch(:application)}/current -C #{config_file}"
        end
      end
    end
  end
end

set :format, :pretty
#set :log_level, :trace
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
