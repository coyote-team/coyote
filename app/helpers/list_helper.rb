# frozen_string_literal: true

module ListHelper
  def link_to_list_item(*args, &block)
    options = combine_options(args.extract_options!, class: "list-item")
    content_tag(:li) do
      link_to(*args, options, &block)
    end
  end

  def list(options = {})
    component(defaults: {class: "list"}, options: options) { yield }
  end

  def list_item_label(label = nil)
    return "" unless label.present? || block_given?
    content_tag(:span, class: "list-item-label") { block_given? ? yield : label }
  end

  def list_item_value(value = nil)
    return "" unless value.present? || block_given?
    content_tag(:span, class: "list-item-value") { block_given? ? yield : value }
  end

  def list_of(items, options = {}, &block)
    list(options) { component_items(items, defaults: {class: "list-item"}, &block) }
  end
end
