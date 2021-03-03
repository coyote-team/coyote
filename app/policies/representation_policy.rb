# frozen_string_literal: true

# Protects Representation objects
# @see Representation
# @see RepresentationsController
class RepresentationPolicy < ApplicationPolicy
  def approve?
    return true if organization_user.admin?
    organization_user.editor? && instance&.ready_to_review?
  end
  alias_method :reject?, :approve?

  # @return [Boolean] whether or not the user can create representations for this organization
  def create?
    return true if organization_user.editor?
    organization_user.author? && instance.resource.assigned_to?(organization_user.user)
  end

  alias_method :new?, :create?

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
    organization_user.author? && organization_user.user == instance.author
  end

  alias_method :edit?, :update?
  alias_method :destroy?, :update?
end
