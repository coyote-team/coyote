# frozen_string_literal: true

module ConfirmationHelper
  def confirmation_pattern(text)
    text = text.gsub(/([\[\]\(\)\.-])/) { |match| Regexp.escape(match) } # rubocop:disable Style/RedundantRegexpEscape
    "^#{text}$"
  end
end
