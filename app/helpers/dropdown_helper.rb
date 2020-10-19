# frozen_string_literal: true

module DropdownHelper
  def dropdown(options = {})
    label = options.delete(:label)
    title = options.delete(:title)
    toggle_options = options.delete(:toggle) || {}
    wrapper_options = options.delete(:wrapper) || {}
    menu_options = combine_options({class: "dropdown-menu"}, options)

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
      data:  {toggle: "dropdown"},
      type:  "button")
    toggle = tag.button(label, toggle_options)

    wrapper_options = combine_options(wrapper_options, class: "dropdown")

    menu = tag.ul(menu_options) { block_given? ? yield : nil }
    safe_join([
      title_tag,
      tag.div(safe_join([toggle, menu]), wrapper_options),
    ])
  end

  def dropdown_for(items, options = {}, &block)
    item_tags = safe_join(items.map { |item|
      dropdown_option(item, &block)
    })

    dropdown(options) { item_tags }
  end

  def dropdown_option(option)
    tag.li(class: "dropdown-menu-item") { block_given? ? yield(option) : option }
  end
end
