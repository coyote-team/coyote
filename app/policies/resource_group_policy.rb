# Protects ResourceGroup objects
class ResourceGroupPolicy < ApplicationPolicy
  # @return [Boolean] all users can view groups
  def index?
    true
  end

  alias show? index?

  # @return [Boolean] only admins can create or edit groups
  def create?
    user.admin?
  end

  alias new? create?
  alias update? create?
  alias edit? create?
  alias destroy? create?
end
