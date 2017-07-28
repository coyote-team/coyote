module Coyote
  # Helper methods for writing controller unit tests
  module ControllerTestMacros
    # @param user [User] the user to login
    def controller_login(user)
      # HACK: https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs
      # You can't use Devise's ControllerHelpers because they require you to create a User in the database,
      # which isn't helpful in a unit test
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      subject.current_user = user
    end

    # Remove the stub set by controller_login
    # @see #controller_login
    def controller_logout
      allow(request.env['warden']).to receive(:authenticate!).and_call_original
      subject.current_user = nil
    end
  end
end
