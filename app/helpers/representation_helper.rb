# frozen_string_literal: true

module RepresentationHelper
  REPRESENTATION_STATUS_CLASSES = {
    ready_to_review: "partial",
    approved:        "success",
    not_approved:    "warning",
  }.freeze

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
    tag_class = REPRESENTATION_STATUS_CLASSES[representation.status.to_sym]
    content_tag(tag, class: "tag tag--#{tag_class}") do
      block_given? ? yield : representation.status.to_s.titleize
    end
  end
end
