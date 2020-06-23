# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_status_checks
#
#  id          :bigint           not null, primary key
#  response    :integer          not null
#  source_uri  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  resource_id :bigint
#
# Indexes
#
#  index_resource_status_checks_on_resource_id  (resource_id)
#
class ResourceStatusCheck < ApplicationRecord
  belongs_to :resource
end
