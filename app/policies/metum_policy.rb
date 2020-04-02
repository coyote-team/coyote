# frozen_string_literal: true

# Protects Metum objects
# @see Metum
class MetumPolicy < ApplicationPolicy
  # @return [Boolean] only admins can create or edit meta
  def create?
    user.admin?
  end

  alias new? create?
  alias update? create?
  alias edit? create?
  alias destroy? create?

  # @return [Boolean] all users can view meta
  def index?
    true
  end

  alias show? index?
end
