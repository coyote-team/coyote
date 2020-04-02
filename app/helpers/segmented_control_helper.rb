# frozen_string_literal: true

module SegmentedControlHelper
  def icon(icon, options = {})
    return "" if icon.blank?

    options = combine_options(options, aria: {hidden: true}, class: "icon-#{icon}")
    content_tag(:i, options) { "" }
  end

  # Returns a component
  def segmented_control(options = {})
    component(defaults: {class: "segmented-control"}, options: options) { yield if block_given? }
  end

  def segmented_control_item(options = {})
    pressed = !!options.delete(:pressed)
    icon = options.delete(:icon)
    title = options.delete(:title)
    options = combine_options({aria: {pressed: pressed.to_s}, type: :button}, options)
    content_tag(:li, class: "segmented-control-item") do
      content_tag(:button, options) do
        icon(icon) + sr_only(title) + (block_given? ? yield : "")
      end
    end
  end

  def sr_only(text, options = {})
    return "" if text.blank?

    options = combine_options(options, class: "sr-only")
    content_tag(:span, options) { text }
  end
end
