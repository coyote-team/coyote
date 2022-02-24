# frozen_string_literal: true

class ApplicationWorker
  def self.inherited(base)
    base.class_eval do
      include Sidekiq::Worker
      sidekiq_options lock: :until_executed, on_conflict: :reject
    end
  end

  private

  # :nocov:
  def on_error(error)
    if defined? Appsignal
      Appsignal.set_error(exception)
    else
      raise error
    end
  end
  # :nocov:
end
