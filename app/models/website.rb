# == Schema Information
#
# Table name: websites
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  url             :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  strategy        :string
#  organization_id :integer          not null
#
# Indexes
#
#  index_websites_on_organization_id  (organization_id)
#

class Website < ApplicationRecord
  validates_presence_of :title, :url
  validates_url :url
  validates_uniqueness_of :url

  has_many :images, dependent: :destroy
  belongs_to :organization, :inverse_of => :websites

  # @return [String] human-friendly name for this Website record
  def to_s
    "Website #{title}"
  end
end
