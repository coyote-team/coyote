# frozen_string_literal: true

# Protects ResourceGroup objects
class ResourceGroupPolicy < ApplicationPolicy
  # @return [Boolean] only admins can create or edit groups
  def create?
    user.admin?
  end

  alias_method :new?, :create?
  alias_method :update?, :create?
  alias_method :edit?, :create?
  alias_method :destroy?, :create?

  # @return [Boolean] all users can view groups
  def index?
    true
  end

  alias_method :show?, :index?

  def view_webhook_uri?
    user.admin?
  end
end
