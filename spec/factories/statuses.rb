# == Schema Information
#
# Table name: statuses
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :status do
    title "Ready to review"
  end
end
