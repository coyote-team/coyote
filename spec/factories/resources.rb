# == Schema Information
#
# Table name: resources
#
#  id                    :bigint(8)        not null, primary key
#  identifier            :string           not null
#  title                 :string           default("Unknown"), not null
#  resource_type         :enum             not null
#  canonical_id          :string           not null
#  source_uri            :string
#  resource_group_id     :bigint(8)        not null
#  organization_id       :bigint(8)        not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  representations_count :integer          default(0), not null
#  priority_flag         :boolean          default(FALSE), not null
#  host_uris             :string           default([]), not null, is an Array
#
# Indexes
#
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#  index_resources_on_resource_group_id                 (resource_group_id)
#

require 'digest/md5'

FactoryBot.define do
  factory :resource, aliases: %i[subject_resource object_resource] do
    title { 'Mona Lisa' }
    resource_type { 'still_image' }
    sequence(:canonical_id) { |n| Digest::MD5.hexdigest(n.to_s) }
    identifier { "#{title.underscore.gsub(/\s+/, '_')}_#{SecureRandom.hex(2)}" }

    trait :priority do
      priority_flag { true }
    end

    transient do
      resource_group { nil }
      organization { nil }
    end

    after(:build) do |resource, evaluator|
      resource.organization ||= evaluator.organization || build(:organization)
      resource.resource_group ||= evaluator.resource_group || build(:resource_group, organization: resource.organization)
    end

    Coyote::Resource.each_type do |_, type_name|
      trait type_name do
        resource_type { type_name }
      end
    end
  end
end
