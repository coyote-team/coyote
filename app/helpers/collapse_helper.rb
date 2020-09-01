# frozen_string_literal: true

module CollapseHelper
  def collapse(options = {}, &block)
    label = options.delete(:label) || "Additional details"
    toggle_options = {data: {toggle: "collapse--toggled"}}.deep_merge(options.delete(:toggle_options) || {})

    id = options[:id] ||= generate_id
    options = {
      data: {toggle_target: "##{id}"},
    }.deep_merge(options)

    toggle = tag.button(combine_options(toggle_options, class: "collapse-toggle")) {
      safe_join([
        icon(:arrow_right),
        tag.div(class: "collapse-toggle-label") { label },
      ])
    }
    content = tag.div(class: "collapse-content", &block)

    tag.div(combine_options(options, class: "collapse")) do
      safe_join([
        toggle,
        content,
      ])
    end
  end
end
