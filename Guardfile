# frozen_string_literal: true

ignore(/doc_assets/)

# This group allows to skip running RuboCop when RSpec failed.
group :red_green_refactor, halt_on_fail: true do
  guard :rspec, all_after_pass: true, all_on_start: false, cmd: "bundle exec rspec", failed_mode: :keep do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch("spec/spec_helper.rb") { "spec" }

    watch(%r{^app/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.slim)$}) { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$}) { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    watch(%r{^spec/support/(.+)\.rb$}) { "spec" }

    watch("config/routes.rb") { "spec/routing" }
    watch("app/controllers/application_controller.rb") { "spec/controllers" }
    watch("spec/spec_helper.rb") { "spec" }

    watch(%r{^app/views/(.+)/.*\.(erb|slim)$}) { |m| "spec/features/#{m[1]}_spec.rb" }
  end

  guard "brakeman", run_on_start: false, quiet: true, url_safe_methods: %i[get], ignore_file: "config/brakeman.ignore" do
    watch(%r{^app/.+\.(erb|rhtml|rb)$})
    watch(%r{^config/.+\.rb$})
    watch(%r{^lib/.+\.rb$})
    watch("Gemfile")
  end

  guard :rubocop, all_on_start: false, cli: "-D -c .rubocop.yml" do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
  end
end

guard :bundler do
  watch("Gemfile")
end
