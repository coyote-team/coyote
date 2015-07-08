module ApplicationHelper
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
    [controller_name, action_name].join('-') + ' '  + controller_name + ' ' + action_name
  end

  def body_class(class_name="")
    class_name =  body_class_default + ' ' + class_name
    content_for :body_class, class_name
  end

  def current_tag?(*tag)
    #logger.info(tag)
    #logger.info(params[:tag])
    tag.include?(params[:tag])
  end

  def flash_class(level)
    case level.to_sym
      when :notice then "alert alert-info alert-dismissable"
      when :success then "alert alert-success alert-dismissable"
      when :error then "alert alert-warning alert-dismissable"
      when :alert then "alert alert-danger alert-dismissable"
    end
  end

  def admin?
    current_user && current_user.admin?
  end

  def set_markdown
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end

  def to_html(content)
    set_markdown
    @markdown.render(content)
  end
    def to_html(content)
    set_markdown
    @markdown.render(content)
  end

  def to_text(content)
    strip_tags to_html(content)
  end

  def to_html_attr(content)
    h to_text(content)
  end

  def active_controller_check(c_name)
    if controller.controller_name == c_name
      'active '
    else
      ''
    end
  end
end
