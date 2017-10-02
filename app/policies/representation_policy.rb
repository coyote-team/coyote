# Protects Representation objects
# @see Representation
# @see RepresentationsController
class RepresentationPolicy < ApplicationPolicy
  # @return [true] everyone can list representations in their organizations
  def index?
    true
  end

  # @return [true] anyone can view an representation belonging to their organization
  def show?
    true
  end

  # @return [Boolean] whether or not the user can create representations for this organization
  def create?
    organization_user.author?
  end

  alias new? create?

  # @return [Boolean] if the user can change the representation
  def update?
    return true if organization_user.editor?
    organization_user.author? && organization_user == record.author
  end

  alias edit? update?
  alias destroy? update?
end
