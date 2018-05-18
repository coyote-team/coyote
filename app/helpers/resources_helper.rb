# View methods for displaying resources
module ResourcesHelper
  def scope_search_collection
    Resource.ransackable_scopes.map do |scope_name|
      [scope_name.to_s.titleize.split(/\s+/).join(' &amp; ').html_safe, scope_name]
    end
  end

  def resource_group_list
    current_user.resource_groups.map do |c|
      [c.title, c.id]
    end
  end

  def resource_status_list(resource, id: nil, title_tag: :h2)
    return unless resource.statuses.any?

    id ||= "resource-#{resource.id}"
    tags = []

    if resource.unrepresented?
      tags.push(tag_for('Undescribed', type: :neutral, hint: 'Status'))
    elsif resource.partially_complete?
      tags.push(tag_for('Partially Completed', type: :partial, hint: 'Status'))
    elsif resource.approved?
      tags.push(tag_for('Approved', type: :success, hint: 'Status'))
    end

    resource.meta.each do |metum|
      tags.push(metum_tag(metum, tag: :li))
    end

    tags.push(tag_for('Urgent', type: :error)) if resource.priority_flag?

    (
      content_tag(title_tag, class: 'sr-only', id: "tag-list-#{id}") { "Properties for resource ##{resource.id}" } +
        content_tag(:ul, aria: { labelledby: "tag-list-#{id}" }, class: 'tag-list') { tags.join.html_safe }
    ).html_safe
  end
end
