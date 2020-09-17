# frozen_string_literal: true

module AuditHelper
  def change_set(changes, &block)
    changes = Array(changes)
    return "" if changes.all?(&:blank?)

    changes = changes.map(&block) if block_given?
    changes.join(" #{icon(:arrow_right)} ").html_safe
  end
end
