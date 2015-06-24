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
    case level
        when :notice then "alert alert-info"
        when :success then "alert alert-success"
        when :error then "alert alert-error"
        when :alert then "alert alert-error"
    end
  end

  def admin?
    current_user && current_user.has_role?(:admin)
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


  def cache_version
    'v1'
  end
end
