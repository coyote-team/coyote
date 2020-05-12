# frozen_string_literal: true

# Protects Resource objects
# @see Resource
# @see ResourcesController
class ResourcePolicy < ApplicationPolicy
  # @return [Boolean] whether or not the user can create resources for this organization
  def create?
    organization_user.author?
  end

  alias new? create?
  alias create_many? create?

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

  alias edit? update?
  alias destroy? update?
end
