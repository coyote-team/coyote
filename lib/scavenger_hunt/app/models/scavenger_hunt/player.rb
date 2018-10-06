class ScavengerHunt::Player < ScavengerHunt::ApplicationRecord
  has_many :games
  has_many :clues, through: :games
  has_many :survey_answers

  scope(:for_leaderboard, lambda do
    select(
      'DISTINCT(scavenger_hunt_players.id)',
      'scavenger_hunt_players.*',
      'SUM(games.elapsed_time_in_seconds) + SUM(games.penalty_time_in_seconds) AS time_elapsed',
      'SUM(CASE games.ended_at
               WHEN NULL THEN 0
               ELSE 1
           END) AS locations_completed',
      'COUNT(completed_clues.id) AS clues_completed'
    ).
    group(:id).
    joins('JOIN scavenger_hunt_games games ON games.player_id = scavenger_hunt_players.id').
    joins('JOIN scavenger_hunt_clues completed_clues ON completed_clues.game_id = games.id AND completed_clues.ended_at IS NOT NULL').
    order("clues_completed DESC, time_elapsed ASC, locations_completed DESC")
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
