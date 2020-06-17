# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id          :bigint           not null, primary key
#  description :string           not null
#  name        :citext           not null
#  url         :citext           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Represents licenses recognized by Coyote
# @see Representation
class License < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: {case_sensitive: false}, if: :name_changed?
  validates :url, presence: true
end
