# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren necessary to flatten namespace here because of how Rails autoloading works

# @abstract Base class for all staff-only controllers
class Staff::ApplicationController < ApplicationController
  before_action :authorize_staff!

  private

  def authorize_staff!
    raise Coyote::SecurityError unless current_user.staff?
  end
end

# rubocop:enable Style/ClassAndModuleChildren
