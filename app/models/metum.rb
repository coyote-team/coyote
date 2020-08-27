# frozen_string_literal: true

# == Schema Information
#
# Table name: meta
#
#  id              :integer          not null, primary key
#  instructions    :text             default(""), not null
#  is_required     :boolean          default(FALSE), not null
#  name            :citext           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :bigint           not null
#
# Indexes
#
#  index_meta_on_organization_id           (organization_id)
#  index_meta_on_organization_id_and_name  (organization_id,name) UNIQUE
#

# Represents a classification for Representations, such as 'Alt' or 'Long'
# @see https://github.com/coyote-team/coyote/issues/113
class Metum < ApplicationRecord
  DEFAULTS = [
    {
      name:         "Alt",
      instructions: "A brief description enabling a user to interact with the image when it is not rendered or when the user has low vision",
      is_required:  true,
    },
    {
      name:         "Long",
      instructions: "A long description is a lengthier text than a traditional alt-text that attempts to provide a comprehensive representation of an image. Long descriptions can range from one sentence to several paragraphs.",
      is_required:  false,
    },
  ].freeze

  attr_accessor :skip_instructions

  validates :name, :instructions, presence: true, unless: :skip_instructions
  validates :name, uniqueness: {case_sensitive: false, scope: :organization_id}, if: :name_changed?

  belongs_to :organization, inverse_of: :meta

  scope :is_required, -> { where(is_required: true) }
end
