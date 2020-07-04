# frozen_string_literal: true

module PolicyHelper
  PERMISSION_ALIASES = {
    list: :index,
  }.with_indifferent_access.freeze

  def can?(*actions, model)
    model = model.to_s.singularize.classify.safe_constantize unless model.is_a?(ActiveRecord::Base)
    return false if model.blank?
    permissions = policy(model)

    actions.all? { |action| permissions.send(map_policy_permission(action)) }
  end

  def map_policy_permission(action)
    "#{(PERMISSION_ALIASES[action] || action)}?"
  end
end
