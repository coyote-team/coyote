# frozen_string_literal: true

module ToolbarHelper
  def form_toolbar(form, options = {})
    options = combine_options(options, class: "toolbar--footer")

    model_name = form.object.class.model_name.human.titleize
    navigate_back = toolbar_item {
      (form.object.persisted? ? link_to("View this #{model_name}", {action: :show}, class: "button button--neutral") : "".html_safe) +
        link_to("View all #{model_name.pluralize}", {action: :index}, class: "button button--neutral")
    }

    toolbar(options) do
      (
        submit_toolbar_item(form) + navigate_back + (block_given? ? yield : "")
      ).html_safe
    end
  end

  def show_toolbar(instance, options = {})
    delete_title = options.delete(:delete_title) || "Delete"
    edit_or_delete = toolbar_item(tag: :div) {
      item = "".html_safe

      can_edit = options.fetch(:edit) { policy(instance).edit? }
      item << edit_link_to({action: :edit}) if can_edit

      can_delete = options.fetch(:delete) { policy(instance).destroy? }
      item << delete_link_to("Are you sure you want to #{delete_title.downcase} #{instance}?", {action: :show}, title: "#{delete_title} #{instance}") if can_delete

      item
    }

    object_name = instance.class.model_name.human.titleize
    view_all = link_to("View all #{object_name.pluralize}", {action: :index}, class: "button button--outline")

    options = combine_options(options, {class: "toolbar--footer", tag: :nav, title: "Actions"})
    toolbar(options) do
      (edit_or_delete + view_all).html_safe
    end
  end

  def submit_toolbar_item(form, submit_options: {}, cancel_options: {})
    submit_options[:class] = Array(submit_options[:class].presence).push("toolbar-item")
    cancel_options[:class] = Array(cancel_options[:class].presence).push("button button--outline")
    toolbar_item do
      form.button(:submit, submit_options) + link_to("Cancel", :back, cancel_options)
    end
  end

  def toolbar(options = {})
    component(defaults: {class: "toolbar"}, options: options) { yield if block_given? }
  end

  def toolbar_item(options = {})
    component(defaults: {class: "toolbar-item"}, options: options, tag: :li) { yield if block_given? }
  end
end
