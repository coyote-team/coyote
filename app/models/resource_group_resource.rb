# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_group_resources
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  resource_group_id :bigint
#  resource_id       :bigint
#
# Indexes
#
#  index_resource_group_resources_on_resource_group_id  (resource_group_id)
#  index_resource_group_resources_on_resource_id        (resource_id)
#  index_resources_resource_group_join                  (resource_id,resource_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (resource_group_id => resource_groups.id)
#  fk_rails_...  (resource_id => resources.id)
#
class ResourceGroupResource < ApplicationRecord
  belongs_to :resource_group
  belongs_to :resource
end
