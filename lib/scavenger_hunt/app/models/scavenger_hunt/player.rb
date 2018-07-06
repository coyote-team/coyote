class ScavengerHunt::Player < ScavengerHunt::ApplicationRecord
  has_many :games
  has_many :clues, through: :games
  has_many :survey_answers

  def aggregate_time
    games.sum(&:total_time)
  end

  def clue_count
    "#{clues.answered.count}/#{clues.count}"
  end

  def location_count
    "#{games.select("DISTINCT(location_id)").count}/#{ScavengerHunt::Location.count}"
  end
end
