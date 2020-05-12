# frozen_string_literal: true

# View methods for displaying resources
module ResourcesHelper
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
    if current_user.staff?
      current_organization.resource_groups
    else
      current_user.resource_groups
    end.by_default_and_name.map do |c|
      [c.name_with_default_annotation, c.id]
    end
  end

  def resource_link(resource, options = {})
    link_options = options.delete(:link) || {}
    target = options.delete(:href) || resource_path(resource)

    link_to(target, link_options) do
      resource_link_target(resource, options.merge(alt: options[:alt] || "Image for resource ##{resource.id}"))
    end
  end

  # @param target_resource [Resource] the Resource that is being displayed
  # @param representation_dom_id [String] identifies the DOM element which contains a description of the resource
  # @param options [Hash] passed on to to the helper code that builds a link (such as Rails' image_tag method)
  # @return [String] an HTML fragment that best depicts the resource (such as an image thumbnail, or an audio icon) based on the type of resource
  def resource_link_target(resource, options = {})
    if resource.viewable?
      image_tag(resource_content_uri(resource), options)
    else
      "#{resource.name} (#{resource.resource_type})"
    end
  end

  def resource_status_list(resource, id: nil, title_tag: :h2)
    return unless resource.statuses.any?

    id ||= "resource-#{resource.id}"
    tags = []

    if resource.unrepresented?
      tags.push(tag_for("Undescribed", type: :neutral, hint: "Status"))
    elsif resource.partially_complete?
      tags.push(tag_for("Partially Completed", type: :partial, hint: "Status"))
    elsif resource.approved?
      tags.push(tag_for("Approved", type: :success, hint: "Status"))
    end

    resource.meta.each do |metum|
      tags.push(metum_tag(metum, tag: :li))
    end

    tags.push(tag_for("Urgent", type: :error)) if resource.priority_flag?

    (
      content_tag(title_tag, class: "sr-only", id: "tag-list-#{id}") { "Properties for resource ##{resource.id}" } +
        content_tag(:ul, aria: {labelledby: "tag-list-#{id}"}, class: "tag-list") { tags.join.html_safe }
    ).html_safe
  end

  def scope_search_collection
    Resource.ransackable_scopes.map do |scope_name|
      [scope_name.to_s.titleize.split(/\s+/).join(" &amp; ").html_safe, scope_name]
    end
  end
end
