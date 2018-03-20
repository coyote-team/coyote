module DropdownHelper
  def dropdown(label:, title: nil)
    menu_options = { class: 'dropdown-menu' }

    if title.present?
      title_id = id_for(title)
      title_tag = content_tag(:h2, class: 'sr-only', id: title_id) { title }
      menu_options[:aria] = { labelledby: title_id }
    else
      title_tag = ''
    end

    toggle_options = {
      aria: { expanded: false },
      class: 'dropdown-toggle',
      data: { toggle: "dropdown" },
      type: 'button'
    }
    toggle = content_tag(:button, toggle_options) { label }

    menu = content_tag(:ul, menu_options) { block_given? ? yield : nil }
    title_tag + content_tag(:div, class: 'dropdown') { toggle + menu }
  end

  def dropdown_option(option)
    menu_item_options = {
      class: 'dropdown-menu-item'
    }
    content_tag(:li, menu_item_options) { block_given? ? yield(option) : option }
  end

  def dropdown_for(items = [], label: nil, title: nil, &block)
    item_tags = items.map { |item|
      dropdown_option(item, &block)
    }.join.html_safe

    dropdown(label: label, title: title) { item_tags }
  end
end
