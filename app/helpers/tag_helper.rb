# frozen_string_literal: true

module TagHelper
  def tag_for(text, hint: nil, tag: :li, type: status_class_for(text))
    class_name = ["tag", *Array(type).map { |t| "tag--#{t}" }].join(" ")
    content_tag(tag, class: class_name) do
      (hint ? content_tag(:span, class: "sr-only") { "#{hint}: " } : "") + text.to_s.humanize
    end
  end
end
