# frozen_string_literal: true

require "cloudtasker/testing"

# Run all jobs inline - this ensures jobs are called as we run the tests
Cloudtasker::Testing.inline!
