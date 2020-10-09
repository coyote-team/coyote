# frozen_string_literal: true

module DropdownHelper
  def dropdown(options = {})
    label = options.delete(:label)
    title = options.delete(:title)
    toggle_options = options.delete(:toggle_options) || {}
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
      type:  "button",
    )
    toggle = tag.button(label, toggle_options)

    menu = tag.ul(menu_options) { block_given? ? yield : nil }
    safe_join([
      title_tag,
      tag.div(safe_join([toggle, menu]), class: "dropdown"),
    ])
  end

  def dropdown_for(items = [], label: nil, title: nil, &block)
    item_tags = safe_join(items.map { |item|
      dropdown_option(item, &block)
    })

    dropdown(label: label, title: title) { item_tags }
  end

  def dropdown_option(option)
    menu_item_options = {
      class: "dropdown-menu-item",
    }
    tag.li(block_given? ? yield(option) : option, menu_item_options)
  end
end
