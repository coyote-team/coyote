# Protects Context objects
class ContextPolicy < ApplicationPolicy
  # @return [Boolean] all users can view contexts
  def index?
    true
  end

  alias show? index?

  # @return [Boolean] only admins can create or edit contects
  def create?
    user.admin?
  end

  alias new? create?
  alias update? create?
  alias edit? create?
  alias destroy? create?
end
