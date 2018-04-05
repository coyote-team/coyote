module DropdownHelper
  def dropdown(options: nil, label:, id: nil, &block)
    id ||= label.parameterize
    toggle_options = {
      aria: {
        expanded: false
      },
      class: 'dropdown-toggle',
      data: {
        toggle: "dropdown"
      },
      id: id,
      type: 'button'
    }
    toggle = content_tag(:button, toggle_options) { label }

    menu_options = {
      aria: {
        labelledby: id
      },
      class: 'dropdown-menu',
      tabindex: -1
    }
    menu = content_tag(:ul, menu_options) { block_given? ? yield : options }

    content_tag(:div, class: 'dropdown') { "#{toggle}#{menu}".html_safe }
  end

  def dropdown_option(option)
    menu_item_options = {
      class: 'dropdown-menu-item'
    }
    content_tag(:li, menu_item_options) { block_given? ? yield(option) : option }
  end

  def dropdown_with_options(options = [], label:, id: nil, &block)
    option_tags = options.map { |option|
      dropdown_option(option, &block)
    }.join.html_safe

    dropdown(options: option_tags, label: label, id: id)
  end
end
