# frozen_string_literal: true

# == Schema Information
#
# Table name: representations
#
#  id           :bigint           not null, primary key
#  content_type :string           default("text/plain"), not null
#  content_uri  :citext
#  language     :citext           not null
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
  attr_reader :rejection_reason

  belongs_to :resource, inverse_of: :representations, counter_cache: true
  belongs_to :metum
  belongs_to :author, inverse_of: :authored_representations, class_name: :User
  belongs_to :license

  has_one :organization, through: :resource
  has_many :rejections, class_name: "RepresentationRejection", inverse_of: :representation, dependent: :destroy

  enum status: Coyote::Representation::STATUSES

  validates :language, presence: true
  validate :must_have_text_or_content_uri

  delegate :name, :source_uri, to: :resource, prefix: true
  delegate :name, to: :metum, prefix: true
  delegate :description, :name, to: :license, prefix: true
  delegate :name, to: :author, prefix: true

  scope :by_ordinality, -> { order("#{table_name}.ordinality ASC NULLS LAST, #{table_name}.created_at ASC") }
  scope :by_status, ->(descending: false) { order(Arel.sql("(case #{table_name}.status when 'approved' then 0 when 'ready_to_review' then 1 else 2 end) #{descending ? "DESC" : "ASC"}")) }
  scope :by_status_and_ordinality, -> { by_status.by_ordinality.by_creation }
  scope :with_distinct_meta, -> { Representation.default_scoped.select("DISTINCT ON(metum_id) metum_id, *").from(by_ordinality, table_name).unscope(:order) }
  scope :with_metum, ->(metum_id) { where(metum_id: metum_id) }
  scope :with_metum_named, ->(name) { joins(:metum).where(meta: {name: name}) }
  scope :with_author, ->(author) { where(author_id: author) }

  audited

  acts_as_list column: :ordinality, scope: [:resource_id]

  before_save :clean_text
  before_create :set_ordinality
  after_create :check_assignment
  before_destroy :destroy_assignments
  after_save :sync_assignment_status, if: :status_changed?

  after_commit :notify_webhook!, if: :should_notify_webhook?
  delegate :notify_webhook!, to: :resource, allow_nil: true

  def self.clean_text(text)
    HTMLEntities.new(:expanded).decode(text.to_s.strip).squish
  end

  def self.find_or_initialize_by_text(text, extra = {})
    find_or_initialize_by(extra.merge(text: clean_text(text)))
  end

  # @see https://github.com/activerecord-hackery/ransack#using-scopesclass-methods
  def self.ransackable_scopes(_ = nil)
    %i[approved by_ordinality by_status_and_ordinality not_approved ready_to_review]
  end

  def assignments
    Assignment.where(resource_id: resource_id, user_id: author_id)
  end

  def previous_rejection_for?(user)
    (user == author && rejections.by_creation(:desc).first) ||
      RepresentationRejection.where(representation: resource.representations.not_approved.with_author(user)).by_creation(:desc).first
  end

  def rejection_reason=(new_reason)
    rejections.build(
      reason:  new_reason,
      user_id: Thread.current[User::ID_KEY],
    )
  end

  def status_value
    if approved?
      0
    elsif ready_to_review?
      1
    else
      2
    end
  end

  def to_s
    "Description #{self[:id]}"
  end

  private

  # If a user has described a resource, we want to retroactively ensure they have an assignment to
  # that resource - we'll also mark it as complete, since they just described it. That status is
  # subject to rollback if the description is rejected.
  def check_assignment
    assignments.upsert({
      resource_id: resource_id,
      status:      :complete,
      user_id:     author_id,
    }, unique_by: %i[resource_id user_id])
  end

  def clean_text
    self.text = self.class.clean_text(text)
  end

  def destroy_assignments
    assignments.delete_all
  end

  def must_have_text_or_content_uri
    return if text.present?
    return if content_uri.present?
    errors.add(:text, "Either text or content URI must be present")
  end

  def set_ordinality
    self.ordinality ||= resource.representations.where(metum_id: metum_id).count.succ
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

  def sync_assignment_status
    # Effectively 'unassign' users if the thing was marked as not approved
    assignment_status = not_approved? ? :deleted : :complete
    assignments.update_all(status: assignment_status)
  end
end
