# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :group do
    title "MyString"
  end

end
