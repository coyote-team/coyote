# frozen_string_literal: true

# Protects Assignment objects with policies.
class AssignmentPolicy < ApplicationPolicy
  # @return [Boolean] if the user is a admin, they can work with assignments
  def index?
    user.admin?
  end

  alias_method :show?, :index?
  alias_method :create?, :index?
  alias_method :new?, :index?
  alias_method :update?, :index?
  alias_method :edit?, :index?
  alias_method :destroy?, :index?
end
