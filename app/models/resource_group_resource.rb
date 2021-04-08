# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_group_resources
#
#  id                :bigint           not null, primary key
#  is_auto_matched   :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  resource_group_id :bigint
#  resource_id       :bigint
#
# Indexes
#
#  index_resource_group_resources_on_resource_group_id  (resource_group_id)
#  index_resource_group_resources_on_resource_id        (resource_id)
#  index_resources_resource_group_join                  (resource_id,resource_group_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (resource_group_id => resource_groups.id)
#  fk_rails_...  (resource_id => resources.id)
#
class ResourceGroupResource < ApplicationRecord
  belongs_to :resource_group
  belongs_to :resource

  before_save :mark_as_manual

  private

  # Any linkage between a resource group and a resource that happens through a UI is considered an
  # explicit linkage, and so we make sure it's not marked as auto-matched. This will prevent the
  # automatic deletion of auto-matched join records when a resource group changes its auto-matching
  # URIs
  def mark_as_manual
    self.is_auto_matched = false
  end
end
