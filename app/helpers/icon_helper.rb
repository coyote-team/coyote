# frozen_string_literal: true

module IconHelper
  def icon(icon, options = {})
    return "" if icon.blank?

    prefix = options.delete(:prefix)
    icon = icon.to_s.dasherize
    icon = "#{icon}-outline" unless icon.ends_with?("-outline")
    options = combine_options(options, aria: {hidden: true}, class: "icon-#{icon}")
    icon = tag.i(options)
    return icon if prefix.blank?

    safe_join([tag.span(prefix), icon])
  end
end
