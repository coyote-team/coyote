class TagsInput < SimpleForm::Inputs::CollectionInput
  enable :placeholder

  def input(wrapper_options = {})
    @collection ||= @builder.object.send(attribute_name)
    label_method, value_method = detect_collection_methods

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options.reverse_merge!(multiple: true)

    @builder.collection_select(
      attribute_name, collection, value_method, label_method,
      input_options, merged_input_options
    )
  end
end
