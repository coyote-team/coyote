class ScavengerHunt::Answer < ScavengerHunt::ApplicationRecord

  before_create :set_is_correct

  belongs_to :clue
  belongs_to :resource

  scope :is_correct, -> { where(is_correct: true) }

  private

  def set_is_correct
    self.is_correct = resource_id == clue.representation.resource_id
    clue.touch(:ended_at) if is_correct?
    true
  end
end
