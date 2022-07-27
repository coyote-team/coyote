# frozen_string_literal: true

module FilterHelper
  include PermittedParameters

  def applied_filters
    toolbar_item(class: "toolbar-item--start") do
      safe_join(record_filter.applied_filters.map { |key, value|
        Array(value).map { |value| remove_filter_link(key, value) }
      }.flatten.compact)
    end
  end

  def filter_name_for(filter, value)
    default = case filter.to_s
    when "scope"
      # Explicit ActiveRecord scopes!
      value.to_s.humanize
    else
      filter.to_s.humanize
    end

    namespace = "#{record_filter.i18n_key}.#{filter}"
    t(
      "#{namespace}.#{value}",
      default: t(namespace, default: default, value: record_filter.value_for(filter, value)),
    )
  end

  def filter_scopes(*scopes)
    scopes.flatten.map do |scope|
      [filter_name_for(:scope, scope), scope]
    end
  end

  def remove_filter_link(filter, value)
    # Sorting doesn't appear as an applied filter
    return if filter.to_s == "s"

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

  def sort_dropdown(options = {}, &block)
    content = capture(&block)
    prefix = @_active_sort_label.presence || "Sort by"
    options[:label] ||= icon(:chevron_down, prefix: prefix)
    options[:toggle] = combine_options(options[:toggle] || {}, class: "button button--round")
    @_active_sort = nil
    dropdown(options) { content }
  end

  def sort_form(q, options = {}, &block)
    options[:method] = "GET"
    options[:class] = "form form--sort"
    content = capture(&block)

    permitted_params = params.fetch(:q, {}).permit(*RESOURCE_FILTERS.reject{ |n| n == :s })

    hidden_fields = permitted_params.to_h.map do
      |key, value| tag.input(value:value, type:'hidden', name: "q[#{key}]")
    end.flatten

    tag.form(safe_join([content, hidden_fields]), options)
  end

  def sort_select(options = {}, &block)
    content = capture(&block)
    tag.div(safe_join([
      tag.label("Sort order", for: "resource_sort_options", class: 'form-field-label'),
      tag.select(content, id: "resource_sort_options", name: "q[s]")
    ]), class: 'form-field')
  end

  def sort_option(attribute, direction, label)
    sort = "#{attribute} #{direction}"
    active_sort = params.dig(:q, :s)

    options = {value: sort}.tap do |o|
      o[:selected] = 1 if active_sort == sort
    end

    tag.option(label, options)
  end

  def sort_link_to(attribute, *args)
    # Extract some simple options
    options = args.extract_options!
    options[:class] = ["sort"] + Array(options[:class])
    direction = args.shift || :asc
    label = args.shift || attribute.to_s.titleize
    sort = "#{attribute} #{direction}"

    # Generate new URL params for the sort
    link = Ransack::Helpers::FormHelper::SortLink.new(record_filter.search, attribute, [sort], params)
    url = link.url_options
    active_sort = params.dig(:q, :s)

    link_to(label, url, options).tap do
      # Determine if the requested sort is the one already applied
      @_active_sort_label = label if active_sort.present? && active_sort == sort
    end
  end
end
