module FilterHelper
  def applied_filters
    # binding.pry
    toolbar_item do
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
    I18n.t("filters.#{record_filter.records.model_name.i18n_key}.#{filter}.#{value}", default: default)
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

    link_to(safe_join([
      icon(:x),
      tag.span(label),
    ]), q: params.fetch(:q, {}).to_unsafe_hash.deep_merge(filter => new_value))
  end
end
