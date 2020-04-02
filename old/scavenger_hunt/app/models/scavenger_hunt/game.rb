# frozen_string_literal: true

require_relative "concerns/metum_attr"

class ScavengerHunt::Game < ScavengerHunt::ApplicationRecord
  include MetumAttr

  ANSWER_METUM_NAME = "Scavenger Hunt: Answer"
  CLUE_METUM_NAME = "Scavenger Hunt: Clue"
  CLUE_POSITION_METUM_NAME = "Scavenger Hunt: Clue Position"
  HINT_METUM_NAME = "Scavenger Hunt: Hint"
  QUESTION_METUM_NAME = "Scavenger Hunt: Question"

  ARCHIVE_ON_REPRESENTATION_CHANGE_META = [
    ANSWER_METUM_NAME,
    CLUE_METUM_NAME,
    HINT_METUM_NAME,
    QUESTION_METUM_NAME,
  ].freeze

  after_create :create_clues
  before_save :record_elapsed_time

  belongs_to :location
  belongs_to :player
  has_many :clues
  has_many :answers, through: :clues
  has_many :hints, through: :clues

  scope :active, -> { where(ended_at: nil) }
  scope :ended, -> { where.not(ended_at: nil) }
  scope :unarchived, -> { where(is_archived: false) }

  hook(::Representation, :create, :update, :destroy) do
    if approved?
      location = ScavengerHunt::Location.find_by(organization_id: resource.organization_id)
      location.games.update(is_archived: true) if location.present? && ARCHIVE_ON_REPRESENTATION_CHANGE_META.include?(metum.title)
    end
  end

  hook(::Resource, :update, :destroy) do
    location = ScavengerHunt::Location.find_by(organization_id: organization_id)
    if location.present?
      scavenger_hunt_representations = representations.approved.joins(:metum).where(meta: {title: ARCHIVE_ON_REPRESENTATION_CHANGE_META})
      location.games.update(is_archived: true) if scavenger_hunt_representations.any?
    end
  end

  def elapsed_time
    ScavengerHunt::Time.new((ended_at || Time.zone.now) - (created_at || Time.zone.now))
  end

  def finished?
    clues.answered.count == clues.count
  end

  def penalty_time
    ScavengerHunt::Time.new(penalty_time_in_seconds)
  end

  def total_time
    elapsed_time + penalty_time
  end

  private

  def create_clues
    representations = location.representations_by_metum(CLUE_METUM_NAME).approved.by_ordinality.group_by(&:resource_id)
    representations = representations.map { |_, all_representations| all_representations.first }
    representations = representations.sort_by { |representation|
      (metum_attr(representation.resource, CLUE_POSITION_METUM_NAME) || 1_000_000).to_s.strip.to_i
    }
    # binding.pry
    representations.each do |representation|
      answer = metum_attr(representation.resource, ANSWER_METUM_NAME)
      clues.create!(answer: answer, game: self, representation: representation) if answer.present?
    end
  end

  def record_elapsed_time
    self.elapsed_time_in_seconds = elapsed_time.seconds
  end
end
