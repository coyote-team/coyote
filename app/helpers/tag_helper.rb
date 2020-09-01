# frozen_string_literal: true

module TagHelper
  def tag_for(text, hint: nil, tag: :li, type: status_class_for(text))
    class_name = ["tag", *Array(type).map { |t| "tag--#{t}" }].join(" ")
    content_tag(tag, class: class_name) do
      safe_join([
        (hint ? self.tag.span(class: "sr-only") { "#{hint}: " } : ""),
        text.to_s.humanize,
      ])
    end
  end

  def tag_list(tags, options = {})
    tag = options.delete(:tag) || :ul
    content_tag(tag, combine_options(options, class: "tag-list")) { safe_join(Array(tags)) }
  end
end
