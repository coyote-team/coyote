# frozen_string_literal: true

module FilterHelper
  def applied_filters
    toolbar_item(class: "toolbar-item--start") do
      safe_join(record_filter.applied_filters.map { |key, value|
        Array(value).map { |value| remove_filter_link(key, value) }
      }.flatten)
    end
  end

  def filter_name_for(filter, value)
    default = case filter.to_s
    when "scope"
      value.humanize
    else
      filter.to_s.humanize
    end

    namespace = "#{record_filter.i18n_key}.#{filter}"
    t(
      "#{namespace}.#{value}",
      default: t(namespace, default: default, value: record_filter.value_for(filter, value)),
    )
  end

  def remove_filter_link(filter, value)
    label = filter_name_for(filter, value)

    # Let's remove the filter from the request
    original_value = params.dig(:q, filter)
    new_value = case original_value
    when Hash
      original_value.except(value)
    when Array
      original_value - Array(value)
    end

    new_query = params.fetch(:q, {}).to_unsafe_hash.deep_merge(filter => new_value)

    link_to(safe_join([
      icon(:close),
      tag.span(label),
    ]),
      {q: new_query},
      class: "filter-remove")
  end
end
