# frozen_string_literal: true

Cloudtasker.configure do |config|
  #
  # If you do not have any Rails secret_key_base defined, uncomment the following.
  # This secret is used to authenticate jobs sent to the processing endpoint
  # of your application.
  #
  # Default with Rails: Rails.application.credentials.secret_key_base
  #
  config.secret = Rails.application.secret_key_base

  #
  # Specify the details of your Google Cloud Task location.
  #
  # This not required in development using the Cloudtasker local server.
  #
  config.gcp_location_id = Credentials.fetch(:google, :region) { "us-east1" }
  config.gcp_project_id = Credentials.fetch(:google, :project) { "coyote" }

  #
  # Specify the namespace for your Cloud Task queues.
  #
  # The gem assumes that a least a default queue named 'my-app-default'
  # exists in Cloud Tasks. You can create this default queue using the
  # gcloud SDK or via the `rake cloudtasker:setup_queue` task if you use Rails.
  #
  # Workers can be scheduled on different queues. The name of the queue
  # in Cloud Tasks is always assumed to be prefixed with the prefix below.
  #
  # E.g.
  # Setting `cloudtasker_options queue: 'critical'` on a worker means that
  # the worker will be pushed to 'my-app-critical' in Cloud Tasks.
  #
  # Specific queues can be created in Cloud Tasks using the gcloud SDK or
  # via the `rake cloudtasker:setup_queue name=<queue_name>` task.
  #
  config.gcp_queue_prefix = "coyote-#{ENV["STAGING"] ? "staging" : Rails.env}-new"

  #
  # Specify the publicly accessible host for your application
  #
  # > E.g. in development, using the cloudtasker local server
  # config.processor_host = 'http://localhost:3000'
  #
  # > E.g. in development, using `config.mode = :production` and ngrok
  # config.processor_host = 'https://111111.ngrok.io'
  #
  host = Credentials.fetch(:app, :host) { "localhost:#{Credentials.fetch(:app, :port) { 3000 }}" }
  config.processor_host = "http#{"s" if Rails.env.production?}://#{host}"

  #
  # Specify the mode of operation:
  # - :development => jobs will be pushed to Redis and picked up by the Cloudtasker local server
  # - :production => jobs will be pushed to Google Cloud Tasks. Requires a publicly accessible domain.
  #
  # Defaults to :development unless CLOUDTASKER_ENV or RAILS_ENV or RACK_ENV is set to something else.
  #
  # config.mode = Rails.env.production? || Rails.env.my_other_env? ? :production : :development

  #
  # Specify the logger to use
  #
  # Default with Rails: Rails.logger
  # Default without Rails: Logger.new(STDOUT)
  #
  # config.logger = MyLogger.new(STDOUT)

  #
  # Specify how many retries are allowed on jobs. This number of retries excludes any
  # connectivity error that would be due to the application being down or unreachable.
  #
  # Default: 25
  #
  config.max_retries = 5

  #
  # Specify the redis connection hash.
  #
  # This is ONLY required in development for the Cloudtasker local server and in
  # all environments if you use any cloudtasker extension (unique jobs, cron jobs or batch jobs)
  #
  # See https://github.com/redis/redis-rb for examples of configuration hashes.
  #
  # Default: redis-rb connects to redis://127.0.0.1:6379/0
  #
  # config.redis = { url: 'redis://localhost:6379/5' }

  #
  # Set to true to store job arguments in Redis instead of sending arguments as part
  # of the job payload to Google Cloud Tasks.
  #
  # This is useful if you expect to process jobs with payloads exceeding 100KB, which
  # is the limit enforced by Google Cloud Tasks.
  #
  # You can set this configuration parameter to a KB value if you want to store jobs
  # args in redis only if the JSONified arguments payload exceeds that threshold.
  #
  # Supported since: v0.10.rc1
  #
  # Default: false
  #
  # Store all job payloads in Redis:
  # config.store_payloads_in_redis = true
  #
  # Store all job payloads in Redis exceeding 50 KB:
  # config.store_payloads_in_redis = 50
end
