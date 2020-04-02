# frozen_string_literal: true

class ScavengerHunt::HintsController < ScavengerHunt::ApplicationController
  before_action :find_game
  before_action :find_clue
  before_action :find_hint, only: %w[show]

  def show
    if @hint.used_at.present? || params[:confirm]
      @hint.update(used_at: Time.zone.now) if @hint.used_at.blank?
      render :really_show
    end
  end
end
