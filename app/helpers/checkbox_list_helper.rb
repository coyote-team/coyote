module CheckboxListHelper
  def checkbox_list(options = {})
    component(defaults: { class: 'checkbox-list' }, options: options) { yield if block_given? }
  end

  def checkbox_list_of(items, options = {})
    checkbox_list(options) { component_items(items, class: 'checkbox-list-item') }
  end

end
