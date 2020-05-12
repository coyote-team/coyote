# frozen_string_literal: true

# == Schema Information
#
# Table name: meta
#
#  id              :integer          not null, primary key
#  instructions    :text             default(""), not null
#  name            :string           not null
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
  validates :name, :instructions, presence: true
  validates :name, uniqueness: {scope: :organization_id}

  belongs_to :organization, inverse_of: :meta

  has_many :representations, inverse_of: :metum
end
