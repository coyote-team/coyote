# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#  default         :boolean          default(FALSE)
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_title  (organization_id,title) UNIQUE
#

# Represents the situation in which a subject is being considered. Determines what strategy we use to present a description of a subject.
# Examples of resource_groups include Web, Exhibitions, Poetry, Digital Interactive, Mobile, Audio Tour
# @see https://github.com/coyote-team/coyote/issues/112
class ResourceGroup < ApplicationRecord
  DEFAULT_TITLE = "Uncategorized".freeze

  validates_presence_of :title
  validates_uniqueness_of :title, scope: :organization_id
  validates_uniqueness_of :default, if: :default?, scope: :organization_id

  has_many :resources, inverse_of: :resource_group

  belongs_to :organization, inverse_of: :resource_groups

  scope :default, -> { where(default: true).first }

  # @return [String] title of this group
  def to_s
    title
  end
end
