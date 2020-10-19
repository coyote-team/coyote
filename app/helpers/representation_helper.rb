# frozen_string_literal: true

module RepresentationHelper
  def representation_audit_license(id)
    @audit_licenses ||= {}
    @audit_licenses.fetch(id) do
      @audit_licenses[id] = License.find_by(id: id)
    end&.name
  end

  def representation_audit_metum(id)
    @audit_meta ||= {}
    @audit_meta.fetch(id) do
      @audit_meta[id] = Metum.find_by(id: id)
    end&.name
  end

  def representation_audit_user(id)
    @audit_users ||= {}
    @audit_users.fetch(id) do
      @audit_users[id] = User.find_by(id: id)
    end&.username
  end

  def representation_status_tag(representation, tag: :span)
    tag_class = status_class_for(representation.status, base: :tag)
    content_tag(tag, class: "tag #{tag_class}") do
      block_given? ? yield : representation.status.to_s.titleize
    end
  end

  # Sorts representations for display (when operating on an array rather than an Arel collection)
  def sorted_representations(representations)
    representations.sort do |a, b|
      comparison = a.ordinality <=> b.ordinality
      comparison = a.status_value <=> b.status_value if comparison.zero?
      comparison = a.created_at <=> b.created_at if comparison.zero?
      comparison = a.id <=> b.id if comparison.zero?
      comparison
    end
  end
end
