# frozen_string_literal: true

class ScavengerHunt::Location < ScavengerHunt::ApplicationRecord
  before_save :set_position
  belongs_to :organization, class_name: "::Organization"
  has_many :games
  has_many :players, through: :games

  delegate :representations, :title, to: :organization

  hook(::Organization, :create) do
    # Create a corresponding location when an organization is created
    meta = [
      {
        title:        ScavengerHunt::Game::ANSWER_METUM_NAME,
        instructions: "A scavenger hunt answer that users must enter when they have found the clue",
      },
      {
        title:        ScavengerHunt::Game::CLUE_METUM_NAME,
        instructions: "A scavenger hunt clue informing players what they're searching for",
      },
      {
        title:        ScavengerHunt::Game::CLUE_POSITION_METUM_NAME,
        instructions: "The order of a clue within the game. Set text to a lower number to move the clue up front.",
      },
      {
        title:        ScavengerHunt::Game::HINT_METUM_NAME,
        instructions: "A scavenger hunt hint helping players to identify a difficult clue",
      },
      {
        title:        ScavengerHunt::Game::QUESTION_METUM_NAME,
        instructions: "The prompt instructing a player on how to enter an answer to a clue. Defaults to 'I think it is...' if nothing is provided on this resource.",
      },
    ]

    location = ScavengerHunt::Location.find_or_initialize_by(organization: self)
    location.tint = "#0000ff"
    location.save!

    meta.each do |attributes|
      metum = Metum.find_or_initialize_by(
        title:        attributes[:title],
        organization: self,
      )
      metum.update!(attributes)
    end
  end

  def played?(by)
    by && games.ended.where(player_id: by.id).any?
  end

  def representations_by_metum(metum_name)
    representations.with_metum_named(metum_name)
  end
end
