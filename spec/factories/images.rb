# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string(255)
#  canonical_id       :string(255)
#  title              :text(65535)
#  priority           :boolean          default(FALSE)
#  status_code        :integer          default(0)
#  page_urls          :text(65535)
#  website_id         :integer
#  group_id           :integer
#  assignments_count  :integer          default(0)
#  descriptions_count :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_images_on_group_id    (group_id)
#  index_images_on_website_id  (website_id)
#

FactoryGirl.define do
  factory :image do
    page_urls ["http://admin.mcachicago.org/Exhibitions/2004/Jose-Damasceno-Observation-Plan"]
    path "/api/v1/attachment_images/thumbs/55917aaa6134300074000014.jpg"
    canonical_id "55917aaa6134300074000014"
    title "Installation view, _José Damasceno: Observation Plan_, MCA Chicago, lobby wall project, Jan 26, 2004–Jan 2, 2005"
    trait :priority do
      priority true
    end
    status_code 0
    website 
    group 
  end
end
