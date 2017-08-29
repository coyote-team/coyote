# == Schema Information
#
# Table name: contexts
#
#  id              :integer          not null, primary key
#  title           :string
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_contexts_on_organization_id  (organization_id)
#

# Context represents the situation in which a subject is being considered. The Context determines what strategy we use to present a description of a subject.
# Examples of contexts include Web, Exhibitions, Poetry, Digital Interactive, Mobile, Audio Tour
# @see https://github.com/coyote-team/coyote/issues/112
class Context < ApplicationRecord
  validates_presence_of :title
  has_many :images, :dependent => :nullify

  belongs_to :organization, :inverse_of => :contexts

  # @return [String] title of this context
  def to_s
    title
  end
end
