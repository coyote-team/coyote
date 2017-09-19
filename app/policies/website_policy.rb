# Protects Website objects
class WebsitePolicy < ApplicationPolicy
  # @return [Boolean] all users can view websites
  def index?
    true
  end

  alias show? index?

  # @return [Boolean] only admins can create/edit/destroy websites
  def create?
    user.admin?
  end

  alias new? create?
  alias update? create?
  alias edit? create?
  alias destroy? create?
end
