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

set :user, 'ubuntu'
set :deploy_to, "/home/ubuntu/data/#{fetch(:application)}"
set :ssh_options, { :forward_agent => true, 
                    :keys => %w(~/.ssh/id_rsa),
                    :auth_methods => %w(publickey)}

set :keep_releases, 5

set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}
set :linked_files, %w{.env .env.production .env.staging} #TODO make this smarter

namespace :deploy do
  before :check:linked_files, "dotenv:upload"
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
end
#https://gist.github.com/andrey-skat/10399224
namespace :assets do
  #Rake::Task['deploy:assets:precompile'].clear_actions
  desc 'Precompile assets locally and upload to servers'
  task :precompile do
    run_locally do
      with rails_env: fetch(:rails_env) do
        execute "RAILS_ENV=#{fetch(:rails_env)} bundle exec rake assets:precompile"
      end
    end
    on roles(:web) do
      #upload assets & manifest
      within release_path do
        with rails_env: fetch(:rails_env) do
          old_manifest_path = "#{current_path}/public/assets/manifest*"
          execute :rm, old_manifest_path if test "[ -f #{old_manifest_path} ]"
          upload!('./public/assets', "#{current_path}/public/", recursive: true)
          execute :rake, "assets:clean"
        end
      end
    end
    run_locally do
      with rails_env: fetch(:rails_env) do
        execute "RAILS_ENV=#{fetch(:rails_env)} bundle exec rake assets:clean"
      end
    end
  end
end

set :format, :pretty
set :log_level, :trace
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
