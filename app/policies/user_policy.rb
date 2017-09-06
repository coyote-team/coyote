# Authorizes access to User objects
# @see (see ApplicationPolicy)
class UserPolicy < ApplicationPolicy
  # @return [true] everyone can list users in their organizations
  def index?
    true
  end

  # @return [true] anyone can view an user belonging to their organization
  def show?
    true
  end

  # @return [true] if the user is a staff member
  # @return [false] otherwise
  # @note eventually we will only add users by invitation, so this whole permission won't be needed
  def create?
    organization_user.staff?
  end

  # @return (see #create?)
  alias new? create?

  # @return [true] if the user is self-editing, or is a staff member
  # @return [false] otherwise
  def update?
    self? || organization_user.staff?
  end

  # @return (see #update?)
  alias edit? update?

  def destroy?
    return false if self?
    organization_user.staff? 
  end

  private

  def self?
    record.id == organization_user.id
  end
end
