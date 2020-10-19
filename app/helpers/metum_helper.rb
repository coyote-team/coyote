# frozen_string_literal: true

module MetumHelper
  def metum_tag(metum, hint: true, tag: :span)
    content_tag(tag, class: "tag tag--info tag--outline") do
      safe_join([
        (hint ? self.tag.span(class: "sr-only") { "Metum: " } : ""),
        metum.to_s,
      ])
    end
  end
end
