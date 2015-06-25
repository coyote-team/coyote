# == Schema Information
#
# Table name: websites
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :website do
    title "MyString"
url "MyString"
  end

end
