# frozen_string_literal: true

# == Schema Information
#
# Table name: resources
#
#  id                    :bigint           not null, primary key
#  host_uris             :string           default([]), not null, is an Array
#  identifier            :string           not null
#  ordinality            :integer
#  priority_flag         :boolean          default(FALSE), not null
#  representations_count :integer          default(0), not null
#  resource_type         :enum             not null
#  source_uri            :citext
#  title                 :string           default("(no title provided)"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  canonical_id          :string           not null
#  organization_id       :bigint           not null
#
# Indexes
#
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#  index_resources_on_source_uri_and_organization_id    (source_uri,organization_id) UNIQUE WHERE ((source_uri IS NOT NULL) AND (source_uri <> ''::citext))
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => restrict ON UPDATE => cascade
#

FactoryBot.define do
  factory :resource, aliases: %i[subject_resource object_resource] do
    title { "Mona Lisa" }
    resource_type { "still_image" }
    identifier { "#{title.underscore.gsub(/\s+/, "_")}_#{SecureRandom.hex(2)}" }

    trait :priority do
      priority_flag { true }
    end

    transient do
      organization { nil }
    end

    after(:build) do |resource, evaluator|
      resource.organization ||= evaluator.organization || build(:organization)
      resource.resource_groups ||= evaluator.resource_groups || [resource.organization.resource_groups.first] || [build(:resource_group, organization: resource.organization)]
    end

    Coyote::Resource.each_type do |_, type_name|
      trait type_name do
        resource_type { type_name }
      end
    end
  end
end
