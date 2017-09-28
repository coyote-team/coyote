# Methods to assist construction of Representation views
# @see RepresentationsController
module RepresentationsHelper
  # @param resource [Resource] the Resource that is being displayed
  # @param representation_dom_id [String] identifies the DOM element which contains a description of the resource
  # @return [String] an HTML fragment that best depicts the resource (such as an image thumbnail, or an audio icon) based on the type of resource
  def resource_link_target(resource,representation_dom_id)
    resource.as_image do |uri,alt_text|
      return image_tag uri, alt: alt_text, "aria-describedby": representation_dom_id
    end

    return "#{resource.title} (#{resource.type})"
  end
end
