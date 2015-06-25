require 'rails/generators/rails/scaffold/scaffold_generator'
module Rails
  module Generators
    class PizzaScaffoldGenerator < ScaffoldGenerator # :nodoc:
      source_root File.expand_path("../templates", __FILE__)
      remove_hook_for :active_record
      remove_hook_for :scaffold_controller
      remove_hook_for :orm
      remove_hook_for :resource_route

      class_option :attachments, type: :boolean, default: false, aliases: "-a"
      class_option :sortable, type: :boolean, default: false

      remove_hook_for :template_engine # prevents calling haml generator twice

      invoke :pizza_controller
      invoke :pizza_model
      invoke :pizza_route

    end
  end
end
