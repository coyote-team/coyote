# frozen_string_literal: true

module Coyote
  module Testing
    # Methods to facilitate writing controller specs
    module ControllerHelpers
      def sign_in(user)
        auth_token = user.auth_tokens.create!
        session[AuthToken::KEY] = auth_token.token
      end

      def sign_out
        cookies.delete(AuthToken::KEY)
        session.delete(AuthToken::KEY)
      end
    end
  end
end

RSpec::Matchers.define :require_login do
  expected = %r{/login}

  match do |response|
    response.headers["Location"].match?(expected)
  end

  description do
    "redirect to /login"
  end
end
