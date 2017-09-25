# == Schema Information
#
# Table name: meta
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  instructions    :text             default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_meta_on_organization_id            (organization_id)
#  index_meta_on_organization_id_and_title  (organization_id,title) UNIQUE
#

# Represents a classification for Descriptions, such as 'Alt' or 'Long'
# @see https://github.com/coyote-team/coyote/issues/113
class Metum < ApplicationRecord
  validates_presence_of :title, :instructions
  validates_uniqueness_of :title, :scope => :organization_id

  belongs_to :organization, :inverse_of => :meta

  has_many :descriptions, :inverse_of => :metum
  has_many :representations, :inverse_of => :metum

  # @return [String] human-friendly description of this Metum
  def to_s
    title
  end
end
