# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :require_user

  def home
    if current_user? && current_user.organizations.any?
      redirect_to current_user.organizations.one? ? organization_path(current_user.organizations.first) : organizations_path
    end
  end
end
