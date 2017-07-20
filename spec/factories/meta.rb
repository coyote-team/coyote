# == Schema Information
#
# Table name: meta
#
#  id           :integer          not null, primary key
#  title        :string
#  instructions :text
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :metum do
    title "Long"
    instructions "A long description is a lengthier text than a traditional alt-text that attempts to provide a comprehensive representation of an image. Long descriptions can range from one sentence to several paragraphs."
  end
end
