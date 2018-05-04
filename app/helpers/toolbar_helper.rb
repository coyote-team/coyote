module ToolbarHelper
  def toolbar(options = {})
    component(defaults: { class: 'toolbar' }, options: options) { yield if block_given? }
  end

  def toolbar_item(options = {})
    component(defaults: { class: 'toolbar-item' }, options: options, tag: :li) { yield if block_given? }
  end
end
