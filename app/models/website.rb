# == Schema Information
#
# Table name: websites
#
#  id              :integer          not null, primary key
#  title           :string
#  url             :string
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

  def to_s
    title
  end

  def get_strategy
    if !strategy.nil? and !strategy.blank?
      strategy.constantize.new
    else
      false
    end
  end

  def strategy_title
    s = get_strategy
    if s
      s.title
    else
      ""
    end
  end

  #TODO should record on website record
  def strategy_check_count
    s = get_strategy
    if s
      s.check_count(self)
    else
      []
    end
  end

  def strategy_update_images(minutes)
    s = get_strategy
    if s
      s.update(self, minutes)
    else
      Rails.logger.info("No strategy set for #{title}")
    end
  end
end
