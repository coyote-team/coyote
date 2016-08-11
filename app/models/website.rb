# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#  strategy   :string(255)
#

class Website < ActiveRecord::Base
  validates_presence_of :title, :url
  validates_url :url
  has_many :images, dependent: :nullify

  def to_s
    title
  end

  def get_strategy
    if strategy
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

  def strategy_check_count
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
