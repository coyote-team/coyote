class ScavengerHunt::Answer < ScavengerHunt::ApplicationRecord

  before_create :set_is_correct

  belongs_to :clue

  scope :is_correct, -> { where(is_correct: true) }

  private

  def clean(text)
    text.downcase.gsub(/[^a-z0-9]/, "")
  end

  def set_is_correct
    self.is_correct = clean(answer) == clean(clue.answer)
    clue.touch(:ended_at) if is_correct?
    true
  end
end
