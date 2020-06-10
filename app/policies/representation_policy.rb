# frozen_string_literal: true

# Protects Representation objects
# @see Representation
# @see RepresentationsController
class RepresentationPolicy < ApplicationPolicy
  # @return [Boolean] whether or not the user can create representations for this organization
  def create?
    return true if organization_user.editor?
    organization_user.author? && record.resource.assigned_to?(organization_user.user)
  end

  alias new? create?

  # @return [true] everyone can list representations in their organizations
  def index?
    true
  end

  # @return [true] anyone can view an representation belonging to their organization
  def show?
    true
  end

  # @return [Boolean] if the user can change the representation
  def update?
    return true if organization_user.editor?
    organization_user.author? && organization_user.user == record.author
  end

  alias edit? update?
  alias destroy? update?
end
