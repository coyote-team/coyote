# frozen_string_literal: true

class MatchResourcesToResourceGroupWorker < ApplicationWorker
  def perform(id)
    resource_group = ResourceGroup.find(id)
    resource_group.match_resources!
  end
end
