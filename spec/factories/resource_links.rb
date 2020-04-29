# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_links
#
#  id                  :bigint           not null, primary key
#  verb                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  object_resource_id  :bigint           not null
#  subject_resource_id :bigint           not null
#
# Indexes
#
#  index_resource_links                         (subject_resource_id,verb,object_resource_id) UNIQUE
#  index_resource_links_on_object_resource_id   (object_resource_id)
#  index_resource_links_on_subject_resource_id  (subject_resource_id)
#
# Foreign Keys
#
#  fk_rails_...  (object_resource_id => resources.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (subject_resource_id => resources.id) ON DELETE => cascade ON UPDATE => cascade
#

FactoryBot.define do
  factory :resource_link do
    subject_resource
    verb { Coyote::ResourceLink::VERB_NAMES.first }
    object_resource

    Coyote::ResourceLink::VERB_NAMES.each do |verb_name|
      # is_version, has_version, etc.
      trait verb_name.to_s.underscore.to_sym do
        verb { verb_name }
      end
    end
  end
end
