# Protects Assignment objects with policies.
class AssignmentPolicy < ApplicationPolicy
  # @return [Boolean] if the user is a admin, they can work with assignments
  def index?
    user.admin?
  end

  alias show? index?
  alias create? index?
  alias new? index?
  alias update? index?
  alias edit? index?
  alias destroy? index?
end
