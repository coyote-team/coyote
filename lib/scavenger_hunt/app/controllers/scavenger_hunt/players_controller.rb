class ScavengerHunt::PlayersController < ScavengerHunt::ApplicationController

  before_action :find_location
  before_action :find_player

  def create
    if @player.update_attributes(player_attributes)
      redirect_to location_survey_questions_path
    else
      render :new
    end
  end

  def new
  end

  def show
    redirect_to new_location_player_path(@location) unless current_player? && current_player.name.present?
  end

  def update
    if @player.update_attributes(player_attributes)
      redirect_to location_survey_questions_path
    else
      render :new
    end
  end

  private

  def find_player
    @player = current_player || ScavengerHunt::Player.new
  end

  def player_attributes
    params[:player].permit(:email, :name)
  end
end
