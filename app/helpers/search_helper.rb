# frozen_string_literal: true

module SearchHelper
  def sort_link_to(attribute, direction, options = {})
    options[:class] = ["sort"] + Array(options[:class])
    label = options.delete(:label).presence || attribute.to_s.titleize
    link_to(label, {sort: {attribute => direction}}, options)
  end
end
