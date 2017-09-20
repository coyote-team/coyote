module Coyote
  # @abstract base class for all Coyote application-specific exceptions
  Exception = Class.new(StandardError)
  
  # Raised when a security violation is detected by application code (vs. by Pundit or by Rails itself)
  SecurityError = Class.new(Exception)
end
