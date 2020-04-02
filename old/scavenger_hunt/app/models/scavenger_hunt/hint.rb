# frozen_string_literal: true

class ScavengerHunt::Hint < ScavengerHunt::ApplicationRecord
  PENALTY = 30.seconds

  after_update :update_game_penalty, if: -> { used_at.present? }
  before_create :set_position

  belongs_to :clue
  belongs_to :representation

  delegate :game, to: :clue

  scope :by_position, -> { order(:position) }
  scope :position_scope, ->(hint) { where(clue_id: hint.clue_id) }
  scope :unused, -> { where(used_at: nil) }
  scope :used, -> { where.not(used_at: nil) }

  def next_hint
    return @next_hint if defined? @next_hint
    @next_hint = clue.hints.where("position > ?", position).first
  end

  def previous_hint
    return @previous_hint if defined? @previous_hint
    @previous_hint = clue.hints.where("position < ?", position).order(position: :desc).first
  end

  private

  def update_game_penalty
    game.update_attribute(:penalty_time_in_seconds, game.hints.used.count * PENALTY)
  end
end
