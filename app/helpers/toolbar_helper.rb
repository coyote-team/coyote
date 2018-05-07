module ToolbarHelper
  def form_toolbar(form, options = {})
    options = combine_options(options, class: 'toolbar--footer')

    model_name = form.object.class.model_name.human
    navigate_back = toolbar_item do
      (form.object.persisted? ? link_to("View this #{model_name.titleize}", { action: :show }, class: 'button button--secondary') : "".html_safe) +
        link_to("View all #{model_name.pluralize.titleize}", { action: :index }, class: 'button button--secondary')
    end

    toolbar(options) do
      (
        submit_toolbar_item(form) + navigate_back + (block_given? ? yield : "")
      ).html_safe
    end
  end

  def show_toolbar(instance, options = {})
    edit_or_delete = toolbar_item(tag: :div) do
      can_edit = options.delete(:edit) || policy(instance).edit?
      edit = can_edit ? link_to('Edit', { action: :edit }, class: 'button button--secondary') : ''

      can_delete = options.delete(:delete) || policy(instance).destroy?
      delete = can_delete ? button_to('Delete', { action: :destroy }, title: "Delete #{instance}", class: 'button button--danger button--secondary', data: { confirm: "Are you sure you want to delete #{instance}?" }, method: :delete) : ''

      (edit + delete).html_safe
    end

    object_name = instance.class.model_name.human.titleize
    view_all = link_to("View all #{object_name.pluralize}", { action: :index }, class: 'button button--secondary')

    options = combine_options(options, { class: 'toolbar--footer', tag: :nav, title: 'Actions' })
    toolbar(options) do
      (edit_or_delete + view_all).html_safe
    end
  end

  def submit_toolbar_item(form)
    toolbar_item do
      form.button(:submit, class: 'toolbar-item') + link_to('Cancel', :back, class: 'button button--secondary button--partial')
    end
  end

  def toolbar(options = {})
    component(defaults: { class: 'toolbar' }, options: options) { yield if block_given? }
  end

  def toolbar_item(options = {})
    component(defaults: { class: 'toolbar-item' }, options: options, tag: :li) { yield if block_given? }
  end
end
