# frozen_string_literal: true

module StatusHelper
  def status_class_for(enum, base: nil)
    class_name = STATUS_CLASSES[enum] || "default"
    base.present? ? "#{base}--#{class_name}" : class_name
  end

  private

  STATUS_CLASSES = {
    # Import status enum
    parsing:         "warning",
    parse_failed:    "error",
    parsed:          "partial",
    importing:       "warning",
    import_failed:   "error",
    imported:        "success",

    # Resource description status
    described:       "success",
    undescribed:     "neutral",

    # Resource assignment status
    assigned:        "success",
    unassigned:      "warning",

    # Representation status enum
    ready_to_review: "partial",
    approved:        "success",
    not_approved:    "warning",

  }.with_indifferent_access.freeze
end
