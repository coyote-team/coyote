class ScavengerHunt::GamesController < ScavengerHunt::ApplicationController

  before_action :find_game, except: :new

  def finish
    if params[:confirm]
      @game.touch(:ended_at)
      redirect_to new_location_player_path(location_id: @game.location_id)
    end
  end

  def new
    location = ScavengerHunt::Location.find(params[:location_id])
    player = current_player || create_player!
    game = player.games.find_or_create_by!(location: location)
    redirect_to game.finished? ? finished_game_path(@game) : game_path(game)
  end

  def show
  end

  private

  def create_player!
    ScavengerHunt::Player.create!(ip: request.ip, user_agent: request.user_agent).tap do |player|
      cookies[current_player_key] = player.id
    end
  end
end
