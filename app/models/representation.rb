# frozen_string_literal: true

# == Schema Information
#
# Table name: representations
#
#  id           :bigint           not null, primary key
#  content_type :string           default("text/plain"), not null
#  content_uri  :string
#  language     :string           not null
#  notes        :text
#  ordinality   :integer
#  status       :enum             default("ready_to_review"), not null
#  text         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  license_id   :bigint           not null
#  metum_id     :bigint           not null
#  resource_id  :bigint           not null
#
# Indexes
#
#  index_representations_on_author_id    (author_id)
#  index_representations_on_license_id   (license_id)
#  index_representations_on_metum_id     (metum_id)
#  index_representations_on_resource_id  (resource_id)
#  index_representations_on_status       (status)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (license_id => licenses.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (metum_id => meta.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (resource_id => resources.id) ON DELETE => restrict ON UPDATE => cascade
#

# An alternate sensory impression of a Resource
class Representation < ApplicationRecord
  belongs_to :resource, inverse_of: :representations, counter_cache: true
  belongs_to :metum, inverse_of: :representations
  belongs_to :author, inverse_of: :authored_representations, class_name: :User
  belongs_to :license, inverse_of: :representations

  has_one :organization, through: :resource

  enum status: Coyote::Representation::STATUSES

  validates :language, presence: true
  validate :must_have_text_or_content_uri

  delegate :name, :source_uri, to: :resource, prefix: true
  delegate :name, to: :metum, prefix: true
  delegate :description, :name, to: :license, prefix: true
  delegate :name, to: :author, prefix: true

  scope :by_ordinality, -> { order(ordinality: :asc) }
  scope :by_status, ->(descending: false) { order(Arel.sql("(case status when 'approved' then 0 when 'ready_to_review' then 1 else 2 end) #{descending ? "DESC" : "ASC"}")) }
  scope :by_length, -> { order(Arel.sql("length(text) DESC")) }
  scope :with_metum, ->(metum_id) { where(metum_id: metum_id) }
  scope :with_metum_named, ->(name) { joins(:metum).where(meta: {name: name}) }

  audited

  delegate :notify_webhook!, to: :resource, allow_nil: true
  after_commit :notify_webhook!, if: :should_notify_webhook?

  # @see https://github.com/activerecord-hackery/ransack#using-scopesclass-methods
  def self.ransackable_scopes(_ = nil)
    %i[approved by_ordinality not_approved ready_to_review]
  end

  def select_default_license(attributes)
    name = attributes.delete(:license)
    self.license_id = attributes.delete(:license_id) ||
      (name.present? && License.where(name: name).first_id) ||
      license_id ||
      License.is_default.first_id
  end

  def select_default_metum(attributes, meta)
    name = attributes.delete(:metum)
    self.metum_id = attributes.delete(:metum_id) ||
      (name.present? && meta.where(name: name).first_id) ||
      metum_id ||
      meta.where(name: "Short").first_id
  end

  def to_s
    "Description #{self[:id]}"
  end

  private

  def must_have_text_or_content_uri
    return if text.present?
    return if content_uri.present?
    errors.add(:text, "Either text or content URI must be present")
  end

  def should_notify_webhook?
    # Always notify when approved representations change
    return true if approved?

    # Check if the status changed
    status_change = previous_changes[:status]
    return false if status_change.blank?

    # Only notify the webhook if it has changed from approved to something else
    status_change.first == Coyote::Representation::STATUSES[:approved]
  end
end
