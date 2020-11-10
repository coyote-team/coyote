# frozen_string_literal: true

module ListHelper
  def link_to_list_item(*args, &block)
    options = combine_options(args.extract_options!, class: "list-item-link")
    tag.li(class: "list-item list-item--has-link") do
      link_to(*args, options, &block)
    end
  end

  def list(options = {})
    component(defaults: {class: "list"}, options: options) { yield }
  end

  def list_item(options = {}, &block)
    component(defaults: {class: "list-item"}, tag: :li, &block)
  end

  def list_item_label(label = nil)
    return "" unless label.present? || block_given?
    tag.span(class: "list-item-label") { block_given? ? yield : label }
  end

  def list_item_value(value = nil)
    return "" unless value.present? || block_given?
    tag.span(class: "list-item-value") { block_given? ? yield : value }
  end

  def list_of(parent, relationship, options = {}, &block)
    wrap = options.delete(:wrap) { true }
    relationship_component(parent, relationship, options) do |items|
      list(options) {
        list_items = items.map { |item|
          content = capture { yield item }
          wrap ? component(defaults: {class: "list-item"}, options: options, tag: :li) { content } : content
        }

        list_items.push(link_to_list_item(view_more_link_content, options[:view_more], class: "view-more")) if options[:view_more]
        safe_join(list_items)
      }
    end
  end
end
