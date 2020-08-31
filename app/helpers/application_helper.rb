# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

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

  # @return [Array<String, Integer>] List of users in the current organization, sorted by name, suitable for use in a select box
  def organizational_user_collection(include_staff: false)
    # @return [Array<String, Integer>] list of users suitable for use in select boxes
    collection = current_organization.active_users.active.order("LOWER(users.first_name) DESC NULLS LAST, LOWER(users.last_name) DESC NULLS LAST, LOWER(users.email) DESC").to_a
    collection.push(current_user) if include_staff && current_user.staff? && !collection.include?(current_user)
    collection.map { |u| [u.username, u.id] }
  end

  def resource
    @resource ||= User.new
  end

  def resource_name
    :user
  end

  def to_html(content)
    if content.blank?
      ""
    else
      raw markdown.render(content)
    end
  end

  # @param content [String] a piece of text annotated with Markdown
  # @return [String] HTML-formatted string, suitable for use in an H1 tag
  # @note This is a hack to avoid <p> tags when rendering resource titles as H1, see https://github.com/vmg/redcarpet/issues/596
  def to_html_title(content)
    html = to_html(content)
    html.gsub!(%r{(?:^<p>|</p>\n)}i, "")
    html.html_safe
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
    alert:        "notification--okay",
    notice:       "notification--okay",
    success:      "notification--success",
    error:        "notification--error",
    notification: "alert--okay",
  }.freeze
end

# rubocop:enable Metrics/ModuleLength
