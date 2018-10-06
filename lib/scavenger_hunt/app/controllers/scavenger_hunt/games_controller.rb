class ScavengerHunt::GamesController < ScavengerHunt::ApplicationController

  before_action :find_game, except: :new

  def finish
    if params[:confirm]
      @game.update_attributes(ended_at: Time.now)
      redirect_to params[:confirm] == "skip" ? locations_path : finished_game_path(@game)
    end
  end

  def finished
  end

  def new
    location = ScavengerHunt::Location.find(params[:location_id])
    player = current_player || create_player!
    game = player.games.find_or_create_by!(location: location)
    redirect_to game.finished? ? finished_game_path(game) : game_path(game)
  end

  def show
  end

  private

  helper_method def all_locations_played?
    return @all_locations_played if defined? @all_locations_played
    @all_locations_played = ScavengerHunt::Location.all.all? do |location|
      location.played?(current_player)
    end
  end

  def create_player!
    ScavengerHunt::Player.create!(default_player_attributes).tap do |player|
      cookies[current_player_key] = player.id
    end
  end
end
