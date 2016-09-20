class PagedownInput < SimpleForm::Inputs::TextInput
  def input
    out = "<div id=\"wmd-button-bar-#{attribute_name}\"></div>#{wmd_input}"

    if input_html_options[:preview]
      out << "<div id=\"wmd-preview-#{attribute_name}\" class=\"wmd-preview\"></div>"
    end

    out.html_safe
  end

  private

  def wmd_input
    @builder.text_area(
      attribute_name,
      input_html_options.merge(
        class: 'wmd-input form-control', id: "wmd-input-#{attribute_name}"
      )
    )
  end
end
