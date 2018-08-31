class ScavengerHunt::Game < ScavengerHunt::ApplicationRecord
  ANSWER_METUM_NAME = "Scavenger Hunt: Answer".freeze
  CLUE_METUM_NAME = "Scavenger Hunt: Clue".freeze
  HINT_METUM_NAME = "Scavenger Hunt: Hint".freeze

  after_create :create_clues

  belongs_to :location
  belongs_to :player
  has_many :clues
  has_many :answers, through: :clues
  has_many :hints, through: :clues

  scope :active, -> { where(ended_at: nil) }

  def finished?
    clues.answered.count == clues.count
  end

  def elapsed_time
    ScavengerHunt::Time.new((ended_at || Time.now) - created_at)
  end

  def penalty_time
    ScavengerHunt::Time.new(hints.used.count * ScavengerHunt::Hint::PENALTY)
  end

  def total_time
    elapsed_time + penalty_time
  end

  private

  def create_clues
    representations = location.representations_by_metum(CLUE_METUM_NAME).approved
    representations.each do |representation|
      answer = representation.resource.representations.with_metum_named(ANSWER_METUM_NAME).approved.first
      clues.create!(answer: answer.text, game: self, representation: representation) if answer.present?
    end
  end
end
