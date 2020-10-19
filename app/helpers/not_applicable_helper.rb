# frozen_string_literal: true

module NotApplicableHelper
  def not_applicable(*args)
    options = args.extract_options!
    label = args.shift
    label.blank? ? sr("Not applicable") : tag.em(label, options)
  end
end
