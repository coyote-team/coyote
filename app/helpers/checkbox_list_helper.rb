module CheckboxListHelper
  def checkbox_list(options = {})
    component(defaults: { class: 'checkbox-list' }, options: options) { yield if block_given? }
  end
end
