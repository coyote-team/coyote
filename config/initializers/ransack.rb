# frozen_string_literal: true

Ransack.configure do |config|
  # Raise errors in dev and test environments if a query contains an unknown predicate or attribute.
  # Don't raise them in production
  config.ignore_unknown_conditions = Rails.env.production?
end
