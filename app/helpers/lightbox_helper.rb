module LightboxHelper
  def lightbox_link(resource, options = {})
    link_options = options.delete(:link) || {}

    if resource.viewable?
      # If the resource is viewable, link to a lightbox
      link_options = combine_options(link_options, { class: 'lightbox-link', data: { lightbox: (resource.source_uri || url_for(resource.uploaded_resource)) }})
      # link_options = combine_options(link_options, { class: 'lightbox-link', data: { lightbox: resource.source_uri }})
      # link_options = combine_options(link_options, { class: 'lightbox-link', data: { lightbox: url_for(resource.uploaded_resource) }})

      alt = options.delete(:alt) || "Lightbox for resource ##{resource.id}"
      options = combine_options(options, { alt: alt, link: link_options })
    end

    resource_link(resource, options)
  end
end
