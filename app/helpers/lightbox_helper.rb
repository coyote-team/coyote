module LightboxHelper
  def lightbox_link(resource, options = {})
    link_options = options.delete(:link) || {}

    if resource.viewable?
      # If the resource is viewable, link to a lightbox
      link_options = combine_options(link_options, { class: 'lightbox-link', data: { lightbox: resource_content_uri }})

      alt = options.delete(:alt) || "Lightbox for resource ##{resource.id}"
      options = combine_options(options, { alt: alt, link: link_options })
    end

    resource_link(resource, options)
  end
end
