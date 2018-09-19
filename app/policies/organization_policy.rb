# Authorizes access to Organization objects
class OrganizationPolicy < ApplicationPolicy
  # @return [true] everyone can view at least the subset of organizations to which they belong
  def index?
    true
  end

  # @return [true] anyone can view an organization
  def show?
    true
  end

  # @return [true] anyone can create an organization
  def create?
    true
  end

  alias new? create?

  # @return [true] if the user is an owner of the organization
  # @return [false] otherwise
  def update?
    organization_user.owner?
  end

  alias edit? update?

  # @return [false] we don't currently support destruction of organizations
  def destroy?
    false
  end
end
