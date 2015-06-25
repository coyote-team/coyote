# == Schema Information
#
# Table name: statuses
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text(65535)
#  created_at  :datetime
#  updated_at  :datetime
#

class Status < ActiveRecord::Base

end
