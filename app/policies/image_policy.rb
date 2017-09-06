# Protects Image objects
class ImagePolicy < ApplicationPolicy
  # @return [true] everyone can list images in their organizations
  def index?
    true
  end

  # @return [true] anyone can view an image belonging to their organization
  def show?
    true
  end

  # @return [Boolean] whether or not the user can create images for this organization
  def create?
    organization_user.author?
  end

  # @return (see #create?)
  alias new? create?

  # @return [Boolean] if the user can change an image belonging to this organization
  def update?
    organization_user.editor?
  end

  # @return (see #update?)
  alias edit? update?

  # @return [Boolean] if the user can delete images belonging to this organization
  def destroy?
    organization_user.editor?
  end
end
