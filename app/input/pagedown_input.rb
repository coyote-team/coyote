class PagedownInput < SimpleForm::Inputs::TextInput
  def input
    out = "<div class=\"wmd-button-bar\" ></div>\n"
    out << "#{@builder.text_area(attribute_name, input_html_options.merge(
      { :class => 'wmd-input'})) }"
    if input_html_options[:preview]
      out << "<div class=\"wmd-preview\"></div>"
    end
    out.html_safe
  end
end
