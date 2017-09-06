# Authorizes access to Description objects
class DescriptionPolicy < ApplicationPolicy
  # @return [true] everyone can list descriptions in their organizations
  def index?
    true
  end

  # @return [true] anyone can view an description belonging to their organization
  def show?
    true
  end

  # @return [Boolean] whether or not user can create descriptions for this organization
  def create?
    organization_user.author?
  end

  # @return (see #create?)
  alias new? create?

  # @return [true] if the user owns the description, or is an editor
  # @return [false] if the user does not own the description and is not an editor
  def update?
    organization_user.editor? || (organization_user.author? && owns_record?)
  end

  # @return (see #update?)
  alias edit? update?

  # @return (see #update?)
  alias destroy? update?

  private

  def owns_record?
    record.user_id == organization_user.id
  end
end
