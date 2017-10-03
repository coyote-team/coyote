# == Schema Information
#
# Table name: resources
#
#  id              :integer          not null, primary key
#  identifier      :string           not null
#  title           :string           default("Unknown"), not null
#  resource_type   :enum             not null
#  canonical_id    :string           not null
#  source_uri      :string
#  context_id      :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_resources_on_context_id                        (context_id)
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#

require 'digest/md5'

FactoryGirl.define do
  factory :resource, aliases: %i[subject_resource object_resource] do
    title 'Mona Lisa'
    resource_type 'still_image'
    sequence(:canonical_id) { |n| Digest::MD5.hexdigest(n.to_s) }
    identifier { "#{title.underscore.gsub(/\s+/,'_')}_#{SecureRandom.hex(2)}" }
    
    transient do
      context nil
      organization nil
    end
    
    after(:build) do |resource,evaluator|
      resource.organization ||= evaluator.organization || build(:organization)
      resource.context      ||= evaluator.context      || build(:context,organization: resource.organization)
    end
    
    Coyote::Resource.each_type do |_,type_name|
      trait type_name do
        resource_type type_name
      end
    end
  end
end
