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
end
