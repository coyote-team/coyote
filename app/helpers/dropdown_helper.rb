module DropdownHelper
  def dropdown(options = {})
    toggle_label = options.delete(:label) || ""
    toggle_id = options.delete(:id) || id_for(toggle_label)
    toggle_options = {
      aria: {
        expanded: false
      },
      class: 'dropdown-toggle',
      data: {
        toggle: "dropdown"
      },
      id: toggle_id,
      type: 'button'
    }
    toggle = content_tag(:button, toggle_options) { toggle_label }

    menu_options = {
      aria: {
        labelledby: toggle_id
      },
      class: 'dropdown-menu'
    }
    menu = content_tag(:ul, menu_options) { block_given? ? yield : options }

    component(defaults: { class: 'dropdown' }, options: options, tag: :div) { "#{toggle}#{menu}".html_safe }
  end

  def dropdown_option(option)
    menu_item_options = {
      class: 'dropdown-menu-item'
    }
    content_tag(:li, menu_item_options) { block_given? ? yield(option) : option }
  end

  def dropdown_for(items = [], options = {}, &block)
    item_tags = items.map { |item|
      dropdown_option(item, &block)
    }.join.html_safe

    dropdown(options) { item_tags }
  end
end
