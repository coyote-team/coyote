worker_count = ENV.fetch("COYOTE_PUMA_WORKERS",1).to_i
thread_count = ENV.fetch("COYOTE_NUM_THREADS",5).to_i

workers worker_count
threads thread_count, thread_count

tag "coyote"
preload_app!

rackup      DefaultRackup
port        ENV["PORT"]     || 3000
environment ENV["RACK_ENV"] || "development"

# Use "path" as the file to store the server info state. Used by "pumactl" to query and control the server

state_path '/tmp/puma.state'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
