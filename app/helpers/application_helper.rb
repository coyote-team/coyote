# rubocop:disable ModuleLength
 
# Contains general, simple view helper code. Designed to keep code out of our views 
# as much as possible
# @see http://guides.rubyonrails.org/action_view_overview.html#overview-of-helpers-provided-by-action-view
module ApplicationHelper
  # @param text [String] the link text to show the user
  # @param path [String] the link target
  # @param icon_name [String] what Font Awesome icon to associate with the link. Optional, defaults to nil.
  # @param options [Hash] passed on to the Rails link_to helper
  # @return [String] HTML link with the given icon attached
  # @see http://fontawesome.io/icons/
  def drop_down_menu_link(text,path,icon_name = nil,options = {})
    classes = %w[fa fa-fw]
    classes << "fa-#{icon_name}" if icon_name

    link_to(path,options) do
      concat tag.i('',class: classes,:'aria-hidden' => true)
      concat "\n"
      concat text
    end
  end

  # @return [Integer] minimum number of password characters we accept
  # @see User
  def minimum_password_length
    User.password_length.min
  end

  # @return [Hash] a collection of User roles with human friendly labels that the current organizational user can assign
  # @see User
  def organizational_user_assignable_roles
    max_assignable_role_rank = organization_user.role_rank

    roles = []

    Coyote::Membership.each_role do |label,role_name,role_rank|
      break if role_rank > max_assignable_role_rank
      roles << [label,role_name]
    end

    roles
  end

  # @return [String] welcome message, including the user's name if someone is logged-in
  def welcome_message
    msg =  "Welcome to Coyote"
    msg << ", #{current_user}!" if current_user
    msg
  end
  
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def body_class_default
    [controller_name, action_name].join('-') + "#{controller_name} #{action_name}"
  end

  def body_class(class_name="")
    class_name = "#{body_class_default} #{class_name}"
    content_for :body_class, class_name
  end

  # Unwraps Devise error messages so they look like flash messages, the way regular application alerts work
  # @param errors [ActiveModel::Errors] a list of model errors set by Devise
  # @note similar approach to https://github.com/plataformatec/devise/wiki/How-To:-Integrate-I18n-Flash-Messages-with-Devise-and-Bootstrap
  def devise_form_errors(errors)
    capture do
      errors.full_messages.each_with_index.map do |msg,idx|
        concat render partial: 'alert', locals: { :flash_type => :error, :flash_message => msg, flash_id: "devise_flash_#{idx}" }
      end
    end
  end
  
  # @param level [String] level of flash message to be styled
  # @return [String] CSS class to use when styling a flash message
  def flash_class(level)
    FLASH_CLASSES.fetch(level.to_sym)
  end

  def image_status_css_class(status_code)
    klass = ""
    case status_code
    when 0
      klass += "undescribed" 
    when 1
      klass += "partial" 
    when 2
      klass += "warning" 
    when 3
      klass += "success" 
    end
    return klass
  end

  def description_css_class(description)
    klass = "item "
    case description.status_id
    when 2
      klass += "success" 
    when 1
      klass += "warning" 
    when 3
      klass += "danger" 
    end
    klass
  end

  def admin?
    current_user.try(:admin?)
  end

  def set_markdown
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  def to_html(content)
    set_markdown
    if content.blank?
      ""
    else
      raw @markdown.render(content)
    end
  end

  def to_text(content)
    if content.blank?
      ""
    else
      strip_tags to_html(content)
    end
  end

  def to_html_attr(content)
    h to_text(content)
  end

  # Used to render top-level navigation, so the current page gets an "active" CSS class applied
  # @param text [String] the link text to display
  # @param path [String] the target of the link
  def nav_menu_link(text,path)
    link_class = current_page?(path) ? "active" : ""

    content_tag(:li,class: link_class) do
      link_to(text,path)
    end
  end

  def audited_value(value)
    if value.kind_of? Array
      value.last
    else
      value
    end
  end

  def license_link(license)
    "https://choosealicense.com/licenses/" + license
  end

  def license_title(license)
    case license
    when "cc0-1.0"
      "Creative Commons Zero v1.0 Universal"
    when "cc-by-sa-4.0"
      "Creative Commons Attribution Share Alike 4.0"
    when "cc-by-4.0"
      "Creative Commons Attribution 4.0"
    end
  end

  FLASH_CLASSES = {
    notice: 'alert-info',
    success: 'alert-success',
    error: 'alert-warning',
    alert: 'alert-danger'
  }.freeze
end

# rubocop:enable ModuleLength
