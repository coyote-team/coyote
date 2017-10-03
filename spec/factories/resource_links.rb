# == Schema Information
#
# Table name: resource_links
#
#  id                  :integer          not null, primary key
#  subject_resource_id :integer          not null
#  verb                :string           not null
#  object_resource_id  :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_resource_links                         (subject_resource_id,verb,object_resource_id) UNIQUE
#  index_resource_links_on_object_resource_id   (object_resource_id)
#  index_resource_links_on_subject_resource_id  (subject_resource_id)
#

FactoryGirl.define do
  factory :resource_link do
    subject_resource
    verb Coyote::ResourceLink::VERB_NAMES.first
    object_resource
  end
end
