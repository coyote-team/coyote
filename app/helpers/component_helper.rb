# frozen_string_literal: true

module ComponentHelper
  # Builds an HTML tag (`tag` parameter) that includes an optional screen
  # reader title and deep-merges options.
  def component(defaults: {}, options: {}, tag: :ul)
    tag = options.delete(:tag) || tag if options.key?(:tag)
    options = combine_options(options.dup, defaults) unless defaults.empty?
    safe_join([
      title_for(options),
      content_tag(tag, options) { yield },
    ])
  end

  def relationship_component(parent, relationship, options = {})
    empty = options.delete(:empty)
    items = parent.send(relationship)
    limit = options.delete(:limit)
    view_more_url = options.delete(:view_more)

    if items.any?
      if limit.present? && items.count > limit
        options[:view_more] = view_more_url
        if items.respond_to?(:limit)
          yield items.limit(limit)
        else
          yield items[0..limit]
        end
      else
        yield items
      end
    else
      empty ||= begin
        item_name = items.respond_to?(:model_name) ? items.model_name.human(count: 2) : parent.class.human_attribute_name(relationship)
        "#{parent.model_name.human} does not have any #{item_name}"
      end

      tag.p(empty, class: "empty")
    end
  end

  def view_more_link(href)
    link_to(view_more_link_content, href, class: "view-more")
  end

  def view_more_link_content
    safe_join([
      tag.strong("View all"),
      icon(:arrow_right),
    ])
  end
end
