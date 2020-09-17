# frozen_string_literal: true

class ImportPolicy < ApplicationPolicy
  # Organization owners can always invite new users of any role. Admin users can invite new users of any rank below admin
  # @return [Boolean] whether or not the user can create an invitation like this one
  def create?
    organization_user.admin?
  end

  def edit?
    create?
  end

  def index?
    create?
  end

  def show?
    create?
  end

  def update?
    create?
  end
end
