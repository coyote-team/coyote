module ListHelper
  def list(options = {})
    component(defaults: { class: 'list' }, options: options) { yield }
  end

  def list_item(options = {})
    options = combine_options(options, class: 'list-item')
    label = options.delete(:label)
    value = options.delete(:value)
    component(defaults: { class: 'list-item' }) do
      (list_item_label(label) + list_item_value(value) + (block_given? ? yield : "")).html_safe
    end
  end

  def list_of(items, options = {}, &block)
    list(options) { component_items(items, defaults: { class: 'list-item' }, &block) }
  end

  def link_to_list_item(*args, &block)
    options = combine_options(args.extract_options!, class: 'list-item')
    content_tag(:li) do
      link_to(*args, options, &block)
    end
  end

  def link_to_list_item_no_border(*args, &block)
    options = combine_options(args.extract_options!, class: 'list-item-no-border')
    content_tag(:li) do
      link_to(*args, options, &block)
    end
  end

  def list_item_label(label = nil)
    return '' unless label.present? || block_given?
    content_tag(:span, class: 'list-item-label') { block_given? ? yield : label }
  end

  def list_item_value(value = nil)
    return '' unless value.present? || block_given?
    content_tag(:span, class: 'list-item-value') { block_given? ? yield : value }
  end
end
