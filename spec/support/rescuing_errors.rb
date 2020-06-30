# frozen_string_literal: true

module Coyote
  module Testing
    # Methods to facilitate writing controller specs
    module RescuingErrors
      def rescuing_errors(&block)
        Credentials.app ||= Credentials.new
        Credentials.app.rescue_from_errors = true
        instance_exec(&block)
      ensure
        Credentials.app.rescue_from_errors = false
      end
    end
  end
end
