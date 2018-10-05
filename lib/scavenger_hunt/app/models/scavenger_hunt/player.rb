class ScavengerHunt::Player < ScavengerHunt::ApplicationRecord
  has_many :games
  has_many :clues, through: :games
  has_many :survey_answers

  scope(:for_leaderboard, lambda do
    select(
      'DISTINCT(scavenger_hunt_players.id)',
      'scavenger_hunt_players.*',
      'COUNT(completed_clues.id) AS clues_completed',
      'SUM(CASE games.ended_at
               WHEN NULL THEN 0
               ELSE 1
           END) AS locations_completed'
    ).
    group(:id, "games.id").
    joins('JOIN scavenger_hunt_games games ON games.player_id = scavenger_hunt_players.id').
    joins('JOIN scavenger_hunt_clues completed_clues ON completed_clues.game_id = games.id AND completed_clues.ended_at IS NOT NULL').
    order("locations_completed DESC, clues_completed DESC")
  end)

  def aggregate_time
    games.unarchived.sum(&:total_time)
  end

  def clue_count
    "#{clues.answered.count}/#{clues.count}"
  end

  def location_count
    "#{games.select('DISTINCT(location_id)').count}/#{ScavengerHunt::Location.count}"
  end
end
