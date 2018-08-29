module ScavengerHunt
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    helper_method def current_player
      return @current_player if defined? @current_player
      cookie = cookies[current_player_key]
      @current_player = Player.find_by!(id: cookie)
    end

    helper_method def current_player?
      current_player.present?
    end

    private

    def current_player_key
      :current_player_id
    end

    def find_clue
      @clue = @game.clues.find(params[:clue_id] || params[:id])
    end

    def find_game
      @game = current_player.games.find(params[:game_id] || params[:id])
    end

    def find_hint
      @hint = @clue.hints.find(params[:hint_id] || params[:id])
    end
  end
end
