module Coyote
  module RequestHeaders
    def api_user_headers(user)
      {
        "X-User-Email" => user.email,
        "X-User-Token" => user.authentication_token
      }
    end
  end
end
