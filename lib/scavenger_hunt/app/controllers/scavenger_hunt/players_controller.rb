class ScavengerHunt::PlayersController < ScavengerHunt::ApplicationController

  before_action :find_player

  def create
    if @player.update_attributes(player_attributes)
      @player.games.active.update_all(ended_at: Time.now)
      redirect_to survey_questions_path
    else
      render :new
    end
  end
  alias update create

  def new
  end

  def show
    redirect_to new_player_path unless current_player? && current_player.name.present?
  end

  private

  def find_player
    @player = current_player || ScavengerHunt::Player.new(default_player_attributes)
  end

  def player_attributes
    params[:player].permit(:email, :name)
  end
end
