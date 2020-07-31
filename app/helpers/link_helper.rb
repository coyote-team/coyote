# frozen_string_literal: true

module LinkHelper
  URL_TEST = /^https?:/.freeze

  def button_link_to(label, url, options = {})
    icon_name = options.delete(:icon)
    options = combine_options({class: "button"}, options)
    if icon_name.present?
      label = safe_join([
        icon(icon_name),
        content_tag(:span, label),
      ])
    end

    link_to(label, url, options)
  end

  def button_options(classnames, default_title, options = {})
    title = options.delete(:title) { default_title }
    classname = Array(classnames).inject("") { |final, modifier| "#{final} button--#{modifier}" }
    options = combine_options({class: classname}, options)

    short_title = options.delete(:shorten) { true } ? title.split(" ").first : title
    unless short_title == title
      options[:aria] ||= {}
      options[:aria][:label] ||= title
      options[:data] ||= {}
      options[:data][:tooltip] = title
    end

    [short_title, options]
  end

  def cancel_link_to(*args)
    options = args.extract_options!
    url = args.pop
    label = args.shift

    title, options = button_options(%i[neutral outline], label || "Cancel", options)
    button_link_to(title, url, options)
  end

  def delete_link_to(*args)
    options = args.extract_options!
    url = args.pop
    confirmation = args.shift
    title, options = button_options("danger", "Delete", options)

    if confirmation
      options[:data] ||= {}
      options[:data][:confirm] = confirmation
      options[:method] ||= :delete
    end
    options[:icon] ||= :trash

    button_link_to(title, url, options)
  end

  def edit_link_to(url, options = {})
    title, options = button_options("info", "Edit", options)
    options[:icon] ||= :pencil
    button_link_to(title, url, options)
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

  def new_link_to(*args)
    options = args.extract_options!
    options[:shorten] = false unless options.key?(:shorten)
    url = args.pop
    label = args.shift
    title, options = button_options("success", label || "New", options)
    options[:icon] ||= :plus
    button_link_to(title, url, options)
  end

  def view_link_to(*args)
    options = args.extract_options!
    url = args.pop
    label = args.shift
    title, options = button_options("partial", label || "View", options)
    options[:icon] ||= :eye
    button_link_to(title, url, options)
  end
end
