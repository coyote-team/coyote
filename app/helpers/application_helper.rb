# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength

# Contains general, simple view helper code. Designed to keep code out of our views
# as much as possible
# @see http://guides.rubyonrails.org/action_view_overview.html#overview-of-helpers-provided-by-action-view
module ApplicationHelper
  def body_class(class_name = "")
    class_name = "#{body_class_default} #{class_name}"
    content_for :body_class, class_name
  end

  def body_class_default
    [controller_name, action_name].join("-") + "#{controller_name} #{action_name}"
  end

  # Unwraps Devise error messages so they look like flash messages, the way regular application alerts work
  # @param errors [ActiveModel::Errors] a list of model errors set by Devise
  # @note similar approach to https://github.com/plataformatec/devise/wiki/How-To:-Integrate-I18n-Flash-Messages-with-Devise-and-Bootstrap
  def devise_form_errors(errors)
    capture do
      errors.full_messages.each_with_index.map do |msg, idx|
        concat render partial: "alert", locals: {flash_type: :error, flash_message: msg, flash_id: "devise_flash_#{idx}"}
      end
    end
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # @return [Array<String, Integer>] list of Endpoints suitable for use in select boxes in Representation forms
  # @see Endpoint
  def endpoint_collection
    Endpoint.sorted
  end

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

  # @return [Integer] minimum number of password characters we accept
  # @see User
  def minimum_password_length
    User.password_length.min
  end

  # Used to render top-level navigation, so the current page gets an "active" CSS class applied
  # @param text [String] the link text to display
  # @param path [String] the target of the link
  def nav_menu_link(text, path)
    link_class = current_page?(path) ? "active" : ""

    content_tag(:li, class: link_class) do
      link_to(text, path)
    end
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
  def organizational_user_collection
    # @return [Array<String, Integer>] list of users suitable for use in select boxes
    collection = current_organization.active_users.active.sort_by { |u| u.username.downcase }
    collection.map! { |u| [u.username, u.id] }
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
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, filter_html: true, autolink: true, tables: true)
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
