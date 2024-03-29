# frozen_string_literal: true

# Protects Resource objects
# @see Resource
# @see ResourcesController
class ResourcePolicy < ApplicationPolicy
  # @return [Boolean] whether or not the user can create resources for this organization
  def create?
    organization_user.editor?
  end

  alias_method :new?, :create?
  alias_method :create_many?, :create?

  # @return [Boolean] if the user can create representations of this resource
  def describe?
    return true if RepresentationPolicy.new(organization_user, Representation.new(resource: instance)).new?
  end

  # @return [true] everyone can list resources in their organizations
  def index?
    true
  end

  # @return [true] anyone can view an resource belonging to their organization
  def show?
    true
  end

  # @return [Boolean] if the user can change an resource belonging to this organization
  def update?
    organization_user.editor?
  end

  alias_method :edit?, :update?
  alias_method :destroy?, :update?
end
