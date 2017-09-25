# == Schema Information
#
# Table name: licenses
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  title      :string           not null
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Represents licenses recognized by Coyote
# @see Representation
class License < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :url,  presence: true, uniqueness: true

  has_many :representations, :inverse_of => :license
end
