# frozen_string_literal: true

module SegmentedControlHelper
  def icon(icon, options = {})
    return "" if icon.blank?

    options = combine_options(options, aria: {hidden: true}, class: "icon-#{icon.to_s.tr("_", "-")}")
    tag.i(options)
  end

  # Returns a component
  def segmented_control(options = {})
    component(defaults: {class: "segmented-control"}, options: options) { yield if block_given? }
  end

  def segmented_control_item(options = {})
    pressed = !!options.delete(:pressed)
    icon = options.delete(:icon)
    title = options.delete(:title)
    sr = options.delete(:sr) { true }
    options = combine_options({aria: {pressed: pressed.to_s}, type: :button}, options)
    tag.li(class: "segmented-control-item") do
      tag.button(options) do
        icon(icon) + (sr ? sr_only(title) : tag.span(title, class: "segmented-control-item-label")) + (block_given? ? yield : "")
      end
    end
  end

  def sr_only(text, options = {})
    return "" if text.blank?

    options = combine_options(options, class: "sr-only")
    tag.span(text, options)
  end
end
