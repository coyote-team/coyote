# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :require_user

  def home
    if current_user? && current_user.organizations.any?
      redirect_to default_landing_path
    end
  end
end
