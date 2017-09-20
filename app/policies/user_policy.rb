# Authorizes access to User objects
# @see (see ApplicationPolicy)
class UserPolicy < ApplicationPolicy
  # @return [false] we don't allow all users to be enumerated
  # @note will change when we build a separate admin UI
  def index?
    false
  end

  # @return [true] anyone can view any user's profile
  def show?
    true
  end

  # @return [false] users only are created via invitation
  def create?
    false
  end

  alias new? create?

  # @return [Boolean] whether or not the user is editing his/her own user record
  def edit?
    self? || organization_user.staff?
  end

  alias update? edit?

  # @return [Boolean] whether or not the user is a staff member
  def destroy?
    organization_user.staff?
  end

  private

  def self?
    record.id == organization_user.id
  end
end
