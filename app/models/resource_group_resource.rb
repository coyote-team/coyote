# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_group_resources
#
#  id                :bigint           not null, primary key
#  resource_group_id :bigint
#  resource_id       :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_resource_group_resources_on_resource_group_id  (resource_group_id)
#  index_resource_group_resources_on_resource_id        (resource_id)
#
class ResourceGroupResource < ApplicationRecord
  belongs_to :resource_group
  belongs_to :resource
end
