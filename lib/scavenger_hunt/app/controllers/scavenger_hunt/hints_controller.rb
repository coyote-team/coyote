class ScavengerHunt::HintsController < ScavengerHunt::ApplicationController

  before_action :find_game
  before_action :find_clue
  before_action :find_hint, only: %w(show)

  def show
    if @hint.used_at.present? || params[:confirm]
      @hint.update_attributes(used_at: Time.now) unless @hint.used_at.present?
      render :really_show
    end
  end
end

