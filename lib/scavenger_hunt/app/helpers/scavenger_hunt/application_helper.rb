module ScavengerHunt
  module ApplicationHelper
    # TODO: Extract the component libraries out to a separate a11y library and
    # make it a dependency of both Coyote and Scavenger Hunt
    include ComponentHelper
    include CombineOptionsHelper
    include IdRegistryHelper
    include ResourcesHelper
    include TitleHelper
    include ToolbarHelper

    def body_class(*classnames)
      @body_class ||= []
      @body_class.push(*classnames)
    end

    def representation_text(representation)
      return unless representation.text.present?
      case representation.content_type
      when "text/html"
        representation.text.html_safe
      else
        simple_format representation.text
      end
    end

    def representation_content(representation)
      case representation.content_type
      when /audio/
        content_tag(:audio, controls: true, src: representation.content_uri) {} +
          representation_text(representation)
      when /image/
        image_tag(representation.content_uri) + representation_text(representation)
      when /video/
        content_tag(:video, controls: true, src: representation.content_uri) {} +
          representation_text(representation)
      else
        representation_text(representation)
      end
    end
  end
end
