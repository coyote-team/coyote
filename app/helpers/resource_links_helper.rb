# frozen_string_literal: true

# Utilities for building ResourceLink views
# @see ResourceLink
module ResourceLinksHelper
  # @param resources [Array<Resource>] the pool of total resources available for linking
  # @param subject_resource [Resource] the potential subject of a new ResourceLink predicate
  # @return [Array<Integer, String>] a collection of linkable objects for use with ResourceLink forms
  def object_resource_choices_for(resources, subject_resource)
    resources.map do |resource|
      option_name = if resource == subject_resource
        "#{resource.name} #{SELF_ID}"
      else
        resource.label
      end
      [option_name, resource.id]
    end
  end

  # @param resource_link [ResourceLink] the object to render as a predicate
  # @return [String] a subject-verb-object predicate that describes the resource link
  def predicate_for(resource_link)
    "#{sanitize(resource_link.subject_resource_name)} #{content_tag(:em, resource_link.verb)} #{sanitize(resource_link.object_resource_name)}".html_safe
  end

  SELF_ID = " (self)"
end
