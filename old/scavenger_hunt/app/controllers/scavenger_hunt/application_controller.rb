# frozen_string_literal: true

module ScavengerHunt
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    helper_method def current_player
      return @current_player if defined? @current_player
      cookie = cookies[current_player_key]
      @current_player = Player.find_by(id: cookie)
    end

    helper_method def current_player?
      current_player.present?
    end

    private

    def current_player_key
      :current_player_id
    end

    def default_player_attributes
      {
        ip:         request.ip,
        user_agent: request.user_agent,
      }
    end

    def find_clue
      require_player!
      @clue = @game.clues.find(params[:clue_id] || params[:id])
    end

    def find_game
      require_player!
      @game = current_player.games.find(params[:game_id] || params[:id])
    end

    def find_hint
      require_player!
      @hint = @clue.hints.find(params[:hint_id] || params[:id])
    end

    def require_player!
      raise ActiveRecord::RecordNotFound if current_player.blank?
    end
  end
end
