# frozen_string_literal: true

module LinkHelper
  URL_TEST = /^https?:/.freeze

  def button_options(classname, default_title, options = {})
    title = options.delete(:title) { default_title }
    options[:class] = ["button button--#{classname}"].push(Array(options[:class].presence))

    short_title = title.split(" ").first
    unless short_title == title
      options[:aria] ||= {}
      options[:aria][:label] ||= title
      options[:data] ||= {}
      options[:data][:tooltip] = title
    end

    [short_title, options]
  end

  def delete_link_to(confirmation, url, options = {})
    title, options = button_options("danger", "Delete", options)
    options[:data] ||= {}
    options[:data][:confirm] = confirmation
    options[:method] ||= :delete
    link_to(safe_join([icon(:trash), content_tag(:span, title)]), url, options)
  end

  def edit_link_to(url, options = {})
    title, options = button_options("info", "Edit", options)
    link_to(safe_join([icon(:pencil), content_tag(:span, title)]), url, options)
  end

  # Used to render top-level navigation, so the current page gets an "active" CSS class applied
  # @param text [String] the link text to display
  # @param path [String] the target of the link
  def nav_menu_link(text, path, exact: false)
    @uri ||= URI.parse(request.url)
    path = url_for(path) unless path.respond_to?(:match?)
    path = URI.parse(path).path if path.match?(URL_TEST)
    is_active = exact ? path == @uri.path : /^#{path}/.match?(@uri.path)
    link_class = is_active ? "active" : ""

    content_tag(:li, class: link_class) do
      link_to(text, path)
    end
  end
end
