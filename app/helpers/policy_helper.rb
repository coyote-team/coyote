# frozen_string_literal: true

module PolicyHelper
  PERMISSION_ALIASES = {
    list: :index,
  }.with_indifferent_access.freeze

  def can?(*actions)
    model = actions.pop.to_s
    permissions = policy(model.singularize.classify.constantize)
    actions.all? { |action| permissions.send(map_policy_permission(action)) }
  end

  def map_policy_permission(action)
    "#{(PERMISSION_ALIASES[action] || action)}?"
  end
end
