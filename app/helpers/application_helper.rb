# frozen_string_literal: true

# Contains general, simple view helper code. Designed to keep code out of our views
# as much as possible
# @see http://guides.rubyonrails.org/action_view_overview.html#overview-of-helpers-provided-by-action-view
module ApplicationHelper
  # @param level [String] level of flash message to be styled
  # @return [String] CSS class to use when styling a flash message
  def flash_class(level)
    FLASH_CLASSES.fetch(level.to_sym)
  end

  # @return [Array<Array>] a collection of languages suitable for use in a select box
  # @see https://github.com/scsmith/language_list
  def language_list
    @language_list ||= LanguageList::COMMON_LANGUAGES.map { |l| [l.common_name, l.iso_639_1] }
  end

  # @param language_code [String] language short code such as 'en'
  # @return [String] human-friendly language name
  # @see https://github.com/scsmith/language_list
  def language_name(language_code)
    LanguageList::LanguageInfo.find(language_code)&.name
  end

  # @return [Hash] a collection of User roles with human friendly labels that the current organizational user can assign
  # @see User
  def organizational_user_assignable_roles
    roles = []

    Coyote::Membership.each_role do |label, role_name, _|
      break unless organization_user.send(:"#{role_name}?")
      roles << [label, role_name]
    end

    roles
  end

  def resource
    @resource ||= User.new
  end

  def resource_name
    :user
  end

  def to_html(content, truncate: nil)
    if content.blank?
      ""
    else
      content = truncate(content, length: truncate) if truncate
      raw markdown.render(content)
    end
  end

  # @return [String] welcome message, including the user's name if someone is logged-in
  def welcome_message
    msg = "Welcome to Coyote"
    msg = "#{msg}, #{current_user}!" if current_user
    msg
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, filter_html: true, autolink: false, tables: true)
  end

  FLASH_CLASSES = {
    alert:        "notification--info",
    notice:       "notification--info",
    success:      "notification--success",
    error:        "notification--error",
    notification: "notification--info",
  }.freeze
end
