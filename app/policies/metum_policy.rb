# frozen_string_literal: true

# Protects Metum objects
# @see Metum
class MetumPolicy < ApplicationPolicy
  # @return [Boolean] only admins can create or edit meta
  def create?
    user.admin?
  end

  alias_method :new?, :create?
  alias_method :update?, :create?
  alias_method :edit?, :create?
  alias_method :destroy?, :create?

  # @return [Boolean] all users can view meta
  def index?
    true
  end

  alias_method :show?, :index?
end
