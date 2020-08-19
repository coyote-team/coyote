# frozen_string_literal: true

class Session < OpenStruct
  INCORRECT_PASSWORD = :incorrect_password
  RETURN_TO_KEY = :return_to
  NO_USER = :no_user

  def authenticate!
    binding.pry
    return NO_USER if user.blank?
    return INCORRECT_PASSWORD if password.blank?

    # If the user has already moved to BCrypt authentication, authenticate that way
    return authenticate_with_digest if user.password_digest?

    # If the user hasn't moved to BCrypt (e.g. they're still on Devise), we'll authenticate against
    # their Devise password and, if successful, update to the new method
    authenticate_with_devise
  end

  private

  def authenticate_with_devise
    devise_password = BCrypt::Password.new(user.encrypted_password)

    if devise_password == password
      user.update(failed_attempts: 0, password: password) # This will encrypt using our BCrypt setup
      user
    else
      record_login_attempt
    end
  end

  def authenticate_with_digest
    if user.authenticate(password)
      user.update(failed_attempts: 0)
      user
    else
      record_login_attempt
    end
  end

  def record_login_attempt
    user.increment!(:failed_attempts)
    INCORRECT_PASSWORD
  end

  def user
    return @user if defined? @user
    @user = email.presence && User.find_by(email: email)
  end
end
