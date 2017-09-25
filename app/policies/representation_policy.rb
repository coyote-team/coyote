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

  # @return [Boolean] if the user can change an representation belonging to this organization
  def update?
    organization_user.editor?
  end

  alias edit? update?
  alias destroy? update?
end
