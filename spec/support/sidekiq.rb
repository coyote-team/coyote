# frozen_string_literal: true

require "sidekiq/testing"

# Run all jobs inline - this ensures jobs are called as we run the tests
Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.around :each, :sidekiq do |example|
    method = case example.metadata[:sidekiq]
    when :fake, false
      :fake
    else
      :inline
    end

    Sidekiq::Testing.send("#{method}!") do
      example.run
    end
  end
end
