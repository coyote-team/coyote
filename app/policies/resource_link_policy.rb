# Protects access to ResourceLink objects
# @see ResourceLink
# @see ResourcePolicy
class ResourceLinkPolicy < ApplicationPolicy
  # @return [true] anyone can view a resource link belonging to their organization
  def show?
    true
  end

  # @return [Boolean] whether or not the user can create resource links for this organization
  def create?
    organization_user.author?
  end

  alias new? create?

  # @return [Boolean] if the user can change an resource belonging to this organization
  def update?
    organization_user.editor?
  end

  alias edit? update?
  alias destroy? update?
end
