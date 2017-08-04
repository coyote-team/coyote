# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organization < ApplicationRecord
end
