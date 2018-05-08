module LightboxHelper
  def lightbox_link(resource, options = {}, &block)
    link_options = options.delete(:link) || {}

    if resource.viewable?
      # If the resource is viewable, provide a link to a lightbox that contains
      # the element, as well as building the lightbox itself

      # Configure the link
      id = options.delete(:id) || id_for(dom_id(resource))
      options = combine_options(options, { aria: { describedby: id } })
      link_options = combine_options(link_options, { class: 'lightbox-link'} )

      link_to("##{id}", link_options) { image_tag(resource.source_uri, options) } +
        link_to('#_', class: 'lightbox', id: id) { image_tag(resource.source_uri, alt: options[:alt], class: 'lightbox-item') }
    else
      # Otherwise, link to the source URI (if present), falling back to the resource itself
      target = resource.source_uri.present? ? resource.source_uri : resource
      link_to(target, link_options) do
        resource_link_target(resource, options)
      end
    end
  end

  # @param target_resource [Resource] the Resource that is being displayed
  # @param representation_dom_id [String] identifies the DOM element which contains a description of the resource
  # @param options [Hash] passed on to to the helper code that builds a link (such as Rails' image_tag method)
  # @return [String] an HTML fragment that best depicts the resource (such as an image thumbnail, or an audio icon) based on the type of resource
  def resource_link_target(resource, options = {})
    if resource.viewable?
      image_tag(resource.source_uri, options)
    else
      "#{resource.title} (#{resource.resource_type})"
    end
  end
end
