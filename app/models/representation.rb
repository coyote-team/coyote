# == Schema Information
#
# Table name: representations
#
#  id           :bigint(8)        not null, primary key
#  resource_id  :bigint(8)        not null
#  text         :text
#  content_uri  :string
#  status       :enum             default("ready_to_review"), not null
#  metum_id     :bigint(8)        not null
#  author_id    :bigint(8)        not null
#  content_type :string           default("text/plain"), not null
#  language     :string           not null
#  license_id   :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  notes        :text
#  endpoint_id  :bigint(8)        not null
#  ordinality   :integer
#
# Indexes
#
#  index_representations_on_author_id    (author_id)
#  index_representations_on_endpoint_id  (endpoint_id)
#  index_representations_on_license_id   (license_id)
#  index_representations_on_metum_id     (metum_id)
#  index_representations_on_resource_id  (resource_id)
#  index_representations_on_status       (status)
#

# An alternate sensory impression of a Resource
class Representation < ApplicationRecord
  belongs_to :resource,     inverse_of: :representations, counter_cache: true
  belongs_to :metum,        inverse_of: :representations
  belongs_to :author,       inverse_of: :authored_representations, class_name: :User
  belongs_to :license,      inverse_of: :representations
  belongs_to :endpoint,     inverse_of: :representations

  has_one :organization, through: :resource

  enum status: Coyote::Representation::STATUSES

  validates :language, presence: true
  validate :must_have_text_or_content_uri

  delegate :title, :source_uri, to: :resource, prefix: true
  delegate :title,              to: :metum,    prefix: true
  delegate :title,              to: :license,  prefix: true
  delegate :name,               to: :endpoint, prefix: true
  delegate :name,               to: :author,   prefix: true
  delegate :identifier,         to: :resource, prefix: true

  scope :by_ordinality, -> { order(ordinality: :asc) }
  scope :by_status, ->(descending: false) { order(Arel.sql("(case status when 'approved' then 0 when 'ready_to_review' then 1 else 2 end) #{descending ? 'DESC' : 'ASC'}")) }
  scope :by_title_length, -> { order(Arel.sql('length(text) DESC')) }
  scope :with_metum_named, ->(title) { joins(:metum).where(meta: { title: title }) }

  audited

  # @see https://github.com/activerecord-hackery/ransack#using-scopesclass-methods
  def self.ransackable_scopes(_ = nil)
    %i[approved not_approved ready_to_review]
  end

  def to_s
    "Description #{self[:id]}"
  end

  private

  def must_have_text_or_content_uri
    return if text.present?
    return if content_uri.present?
    errors.add(:text, 'Either text or content URI must be present')
  end
end
