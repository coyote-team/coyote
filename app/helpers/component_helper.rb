# frozen_string_literal: true

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

  def status_class_for(enum, base: nil)
    class_name = STATUS_CLASSES[enum] || "default"
    base.present? ? "#{base}--#{class_name}" : class_name
  end

  private

  STATUS_CLASSES = {
    # Import status enum
    parsing:         "warning",
    parse_failed:    "error",
    parsed:          "partial",
    importing:       "warning",
    import_failed:   "error",
    imported:        "success",

    # Representation status enum
    ready_to_review: "partial",
    approved:        "success",
    not_approved:    "warning",
  }.with_indifferent_access.freeze
end
