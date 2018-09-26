class ScavengerHunt::Hint < ScavengerHunt::ApplicationRecord
  PENALTY = 30.seconds

  before_create :set_position

  belongs_to :clue
  belongs_to :representation

  scope :by_position, -> { order(:position) }
  scope :position_scope, -> (hint) { where(clue_id: hint.clue_id) }
  scope :unused, -> { where(used_at: nil) }
  scope :used, -> { where.not(used_at: nil) }

  def next_hint
    return @next_hint if defined? @next_hint
    @next_hint = clue.hints.where("position > ?", position).first
  end
end
