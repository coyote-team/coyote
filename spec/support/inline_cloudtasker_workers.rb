# frozen_string_literal: true

require "cloudtasker/testing"

# Run all jobs inline - this ensures jobs are called as we run the tests
Cloudtasker::Testing.inline!

RSpec.configure do |config|
  config.around :each, :cloudtasker do |example|
    method = case example.metadata[:cloudtasker]
    when :fake, false
      :fake
    else
      :inline
    end

    Cloudtasker::Testing.send("#{method}!") do
      example.run
    end
  end
end
