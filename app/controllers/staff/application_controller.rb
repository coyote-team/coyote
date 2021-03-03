# frozen_string_literal: true

# @abstract Base class for all staff-only controllers
class Staff::ApplicationController < ApplicationController
  before_action :authorize_staff!

  private

  def authorize_staff!
    raise Coyote::SecurityError unless current_user.staff?
  end
end
