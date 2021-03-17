# frozen_string_literal: true

module CollapseHelper
  def collapse(options = {}, &block)
    # Give the container an ID so we can toggle the '--toggled' class
    id = options[:id] ||= generate_id

    # Set up a "toggler", which has a `data-toggle-target` attribute pointing to our container, and a `toggle` classname
    toggle_options = {data: {toggle_target: "##{id}", toggle: "collapse--toggled"}}.deep_merge(options.delete(:toggle) || {})
    toggle = tag.button(combine_options(toggle_options, class: "collapse-toggle")) {
      safe_join([
        icon(:chevron_right),
        tag.div(options.delete(:label) || "Additional details", class: "collapse-toggle-label"),
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
