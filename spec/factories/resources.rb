# frozen_string_literal: true

# == Schema Information
#
# Table name: resources
#
#  id                    :bigint           not null, primary key
#  host_uris             :string           default([]), not null, is an Array
#  is_deleted            :boolean          default(FALSE), not null
#  name                  :string           default("(no title provided)"), not null
#  priority_flag         :boolean          default(FALSE), not null
#  representations_count :integer          default(0), not null
#  resource_type         :enum             default("image"), not null
#  source_uri            :citext           not null
#  status                :enum             default("active"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  canonical_id          :citext
#  organization_id       :bigint           not null
#
# Indexes
#
#  index_resources_on_canonical_id                      (canonical_id)
#  index_resources_on_is_deleted                        (is_deleted)
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#  index_resources_on_schemaless_source_uri             (reverse((source_uri)::text) text_pattern_ops)
#  index_resources_on_source_uri                        (source_uri)
#  index_resources_on_source_uri_and_organization_id    (source_uri,organization_id) UNIQUE WHERE ((source_uri IS NOT NULL) AND (source_uri <> ''::citext))
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => restrict ON UPDATE => cascade
#

FactoryBot.define do
  factory :resource, aliases: %i[subject_resource object_resource] do
    name { "Mona Lisa" }
    resource_type { "image" }
    source_uri { Faker::Internet.unique.url }

    trait :priority do
      priority_flag { true }
    end

    after(:build) do |resource, evaluator|
      resource.organization ||= evaluator.organization || build(:organization)
      resource.resource_groups ||= evaluator.resource_groups || [resource.organization.resource_groups.first] || [build(:resource_group, organization: resource.organization)]
    end
  end
end
