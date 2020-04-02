# frozen_string_literal: true

YARD::Rake::YardocTask.new if defined?(YARD)

namespace :coyote do
  desc "Generate docs from YARD and apipie"
  task docs: %i[apipie:static yard]
end
