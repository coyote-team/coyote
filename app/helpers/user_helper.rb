# frozen_string_literal: true

module UserHelper
  def user_tag(user, label: user.to_s)
    user = user.user if user.respond_to?(:user)
    tag.div(class: "user") {
      safe_join([
        image_tag(user.avatar_url, class: "user-avatar"),
        tag.span(label, class: "user-name"),
      ])
    }
  end

  # @return [Array<String, Integer>] List of users in the current organization, sorted by name, suitable for use in a select box
  def users_for_select(users = nil, include_staff: false)
    users ||= current_organization.active_users
    users = users.to_a
    users.push(current_user) if include_staff && current_user.staff? && users.exclude?(current_user)
    users.map { |u| [u.username, u.id] }
  end
end
