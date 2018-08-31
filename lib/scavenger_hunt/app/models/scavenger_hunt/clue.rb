class ScavengerHunt::Clue < ScavengerHunt::ApplicationRecord
  after_save :create_hints
  before_save :set_position

  belongs_to :game
  belongs_to :representation
  has_many :answers
  has_many :hints

  delegate :location, to: :game
  delegate :resource, :text, to: :representation

  default_scope -> { order(:position) }
  scope :answered, -> { where.not(ended_at: nil) }
  scope :position_scope, -> (clue) { where(game_id: clue.game_id) }
  scope :unanswered, -> { where(ended_at: nil) }

  def answered?
    ended_at.present?
  end

  def first_hint
    hints.order(:used_at).first
  end

  def next
    game.clues.unanswered.where("position > ?", position).first
  end

  def prev
    game.clues.unscoped.unanswered.where("position < ?", position).order(position: :desc).first
  end

  private

  def create_hints
    representations = location.representations_by_metum(ScavengerHunt::Game::HINT_METUM_NAME).approved
    representations.each do |representation|
      hints.create!(clue: self, representation: representation)
    end
  end
end
