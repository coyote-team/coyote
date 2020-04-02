# frozen_string_literal: true

module Coyote
  # Raised when a security violation is detected by application code (vs. by Pundit or by Rails itself)
  class SecurityError < RuntimeError
  end
end
