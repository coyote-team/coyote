# == Schema Information
#
# Table name: descriptions
#
#  id         :integer          not null, primary key
#  locale     :string           default("en")
#  text       :text
#  status_id  :integer
#  image_id   :integer
#  metum_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  license    :string           default("cc0-1.0")
#
# Indexes
#
#  index_descriptions_on_image_id   (image_id)
#  index_descriptions_on_metum_id   (metum_id)
#  index_descriptions_on_status_id  (status_id)
#  index_descriptions_on_user_id    (user_id)
#

FactoryGirl.define do
  factory :description do
    locale "en"
    text Faker::Lorem.paragraph
    status 
    image 
    metum 
    user 
  end
end
