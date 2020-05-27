# frozen_string_literal: true

# == Schema Information
#
# Table name: licenses
#
#  id          :bigint           not null, primary key
#  description :string           not null
#  name        :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Represents licenses recognized by Coyote
# @see Representation
class License < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

  has_many :representations, inverse_of: :license
end
