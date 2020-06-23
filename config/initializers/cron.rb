# frozen_string_literal: true

# Specify all your cron jobs below. This will synchronize your list of cron jobs (cron jobs previously created and not listed below will be removed).
unless Rails.env.test?
  Cloudtasker::Cron::Schedule.load_from_hash!(
    # Run job every minute
    some_schedule_name: {
      worker: "CheckResourcesWorker",
      cron:   "0 0 * * *",
    },
  )
end
