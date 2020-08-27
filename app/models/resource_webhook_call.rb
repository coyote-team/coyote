# frozen_string_literal: true

# == Schema Information
#
# Table name: resource_webhook_calls
#
#  id            :bigint           not null, primary key
#  body          :json
#  error         :text
#  response      :integer
#  response_body :text
#  uri           :citext           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :bigint           not null
#
# Indexes
#
#  index_resource_webhook_calls_on_resource_id  (resource_id)
#
class ResourceWebhookCall < ApplicationRecord
end
