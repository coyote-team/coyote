require 'yard'

# see https://github.com/lsegal/yard#generating-documentation
YARD::Rake::YardocTask.new do |t|
end

namespace :coyote do
  desc 'Generate docs from YARD and apipie'
  task :docs => %i[apipie:static yard]
end
