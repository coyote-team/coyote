module UserHelper
  def user_tag(user)
    user = user.user if user.respond_to?(:user)
    tag.div(class: "user") {
      safe_join([
        image_tag(user.avatar_url, class: "user-avatar"),
        tag.span(user.to_s, class: "user-name"),
      ])
    }
  end
end
