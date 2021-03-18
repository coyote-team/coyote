# frozen_string_literal: true

# Protects Assignment objects with policies.
class AssignmentPolicy < ApplicationPolicy
  def create?
    return true if user.admin?
    return true if user.author? && organization.allow_authors_to_claim_resources?
    false
  end
  alias_method :new?, :create?

  def destroy?
    return true if index?
    instance.user_id == user.id
  end

  # @return [Boolean] if the user is a admin, they can work with assignments
  def index?
    user.admin?
  end
  alias_method :show?, :index?
  alias_method :update?, :index?
  alias_method :edit?, :index?

  def scope_users(users)
    return users if user.admin?
    return [user.user] if organization.allow_authors_to_claim_resources?
    []
  end
end
