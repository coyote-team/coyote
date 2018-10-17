module RepresentationHelper
  REPRESENTATION_STATUS_CLASSES = {
    ready_to_review: 'partial',
    approved:        'success',
    not_approved:    'warning'
  }.freeze

  def representation_status_tag(representation, tag: :span)
    tag_class = REPRESENTATION_STATUS_CLASSES[representation.status.to_sym]
    content_tag(tag, class: "tag tag--#{tag_class}") do
      block_given? ? yield : representation.status.to_s.titleize
    end
  end

  def audit_change_to_text(change)
    old_value, new_value = change

    if old_value.present? && new_value.nil?
      %(#{old_value})
    elsif old_value.present? && new_value.blank?
      %(#{old_value} → Value was removed.)
    else
      %(#{old_value} → #{new_value})
    end
  end

  def id_to_title(change, audit_class, audit_attribute)
    old_value, new_value = change
    old_title = audit_class.find_by(id: old_value)&.send(audit_attribute.to_sym)
    new_title = audit_class.find_by(id: new_value)&.send(audit_attribute.to_sym)

    if old_value.present? && new_value.nil?
      old_title
    elsif old_value.present? && new_value.blank?
      old_title
    else
      %(#{old_title} → #{new_title})
    end
  end
end
