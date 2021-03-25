# frozen_string_literal: true

module DropdownHelper
  def dropdown(options = {})
    label = options.delete(:label)
    title = options.delete(:title)
    toggle_options = options.delete(:toggle) || {}
    wrapper_options = options.delete(:wrapper) || {}
    menu_options = combine_options({class: "dropdown-menu dropdown-menu-end"}, options)

    if title.present?
      title_id = id_for(title)
      title_tag = tag.h2(title, class: "sr-only", id: title_id)
      menu_options[:aria] = {labelledby: title_id}
    else
      title_tag = ""
    end

    toggle_options = combine_options(toggle_options,
      aria:  {expanded: false},
      class: "dropdown-toggle",
      data:  {bs_toggle: "dropdown"},
      type:  "button")
    toggle = tag.button(label, toggle_options)

    wrapper_options = combine_options(wrapper_options, class: "dropdown")

    menu = tag.ul(menu_options) { block_given? ? yield : nil }
    safe_join([
      title_tag,
      tag.div(safe_join([toggle, menu]), wrapper_options),
    ])
  end

  def dropdown_option(value = nil, options = {}, &block)
    content = block ? capture(&block) : value
    if content.try(:strip).try(:match?, /<a/)
      tag.li(content, combine_options(options, class: "dropdown-item dropdown-item--has-link"))
    else
      tag.li(content, combine_options(options, class: "dropdown-item"))
    end
  end

  def options_dropdown(options = {}, &block)
    options[:label] ||= icon(:more_vertical)
    options[:toggle] = combine_options(options[:toggle] || {}, {
      class: "button button--quiet button--square button--round",
    })
    options[:wrapper] = combine_options(options[:wrapper] || {}, {
      class: "dropdown--end",
    })
    dropdown(options, &block)
  end
end
