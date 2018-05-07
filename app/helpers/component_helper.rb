module ComponentHelper
  # Builds an HTML tag (`tag` parameter) that includes an optional screen
  # reader title and deep-merges options.
  def component(defaults: {}, options: {}, tag: :ul)
    tag = options.delete(:tag) || tag
    options = combine_options(options, defaults) unless defaults.empty?
    title_for(options) + content_tag(tag, options) { yield }
  end

  # Iterate through a passed-in collection of items, yielding each to an
  # iterator block, and combining them into a content block. Used internally
  # for building helpers like `list_of` or `segmented_control_for`.
  def component_items(items, defaults: {}, options: {}, tag: :li)
    items.map { |item|
      component(defaults: defaults, options: options, tag: tag) { yield item }
    }.join.html_safe
  end
end
