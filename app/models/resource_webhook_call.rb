# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_webhook_calls
#
#  id          :bigint           not null, primary key
#  resource_id :bigint           not null
#  uri         :string           not null
#  body        :json
#  response    :integer
#  error       :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_resource_webhook_calls_on_resource_id  (resource_id)
#
class ResourceWebhookCall < ApplicationRecord
end
