# frozen_string_literal: true

# View methods for displaying resources
module ResourcesHelper
  def cropped_resource_image(resource, options = {})
    options[:aria] ||= {}
    options[:aria][:label] = options[:aria][:label].presence || resource.best_representation.presence || "Image for resource ##{resource.id}"
    options = combine_options(
      options,
      class: "resource-image",
    )
    content = if resource.viewable?
      options[:style] = (
        Array(options[:style]) +
        [%[background-image: url("#{resource_content_uri(resource)}")]]
      ).join("; ")
      ""
    else
      options[:class] = "#{options[:class]} resource-image--not-viewable"
      "#{resource.name} (#{resource.resource_type})"
    end

    tag.span(content, options)
  end

  def resource_content_uri(resource)
    if resource.source_uri.present?
      resource.source_uri
    elsif resource.uploaded_resource.attached?
      # FIXME: Metamagic's, ahem, "magic" is hijacking `url_for` and causing
      # this to explode, so we call the helper method directly rather than
      # using the included one that has been overridden by, ahem, poorly
      # behaving libraries
      Rails.application.routes.url_helpers.url_for(resource.uploaded_resource)
    end
  end

  def resource_group_list
    current_organization.resource_groups.by_default_and_name.map do |c|
      [c.name_with_default_annotation, c.id]
    end
  end

  def resource_host_link(resource)
    return if resource.host_uris.blank?
    uri = resource.host_uris.find { |uri| URI.parse(uri).present? }
    link_to(safe_join([tag.span("View in context"), icon(:external_link)]), uri, target: "_resource_#{resource.id}_host_uri")
  end

  def resource_image(resource, options = {})
    options[:alt] = options[:alt].presence || resource.best_representation.presence || "Image for resource ##{resource.id}"
    if resource.viewable?
      image_tag(resource_content_uri(resource), options)
    else
      "#{resource.name} (#{resource.resource_type})"
    end
  end

  def resource_link(resource, options = {})
    link_options = options.delete(:link) || {}
    target = options.delete(:href) || resource_path(resource)

    link_to(target, link_options) do
      resource_image(resource, options)
    end
  end
end
