class ApplicationWorker
  include Cloudtasker::Worker

  cloudtasker_options lock: :until_executed, on_conflict: :reject


  private

  # :nocov:
  def on_error(error)
    if defined? Raven
      Raven.capture_exception(exception)
    else
      raise error
    end
  end
  # :nocov:
end
