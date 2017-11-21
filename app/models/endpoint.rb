# == Schema Information
#
# Table name: endpoints
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_endpoints_on_name  (name) UNIQUE
#

class Endpoint < ApplicationRecord
  has_many :representations, :inverse_of => :endpoint

  validates :name, presence: true, uniqueness: true

  scope :sorted, -> { order(:name) }
end
