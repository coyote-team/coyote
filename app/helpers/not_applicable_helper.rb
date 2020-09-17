# frozen_string_literal: true

module NotApplicableHelper
  def not_applicable(*args)
    options = args.extract_options!
    label = args.shift
    label.blank? ? sr("Not applicable") : content_tag(:em, label, options)
  end
end
