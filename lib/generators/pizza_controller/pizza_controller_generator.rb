require 'generators/rails/responders_controller_generator'

module Rails
  module Generators
    class PizzaControllerGenerator < RespondersControllerGenerator
      source_root File.expand_path("../templates", __FILE__)
      
      class_option :attachments, type: :boolean, default: false, aliases: "-a"
      class_option :sortable, type: :boolean, default: false

      def copy_view_files
        available_views.each do |view|
          filename = "#{view}.html.haml"
          template "#{filename}", File.join("app/views", controller_file_path, filename), @options
        end
      end

      hook_for :form_builder, :as => :scaffold

      def copy_form_file
        if options[:form_builder].nil?
          filename = "_form.html.haml"
          template "#{filename}", File.join("app/views", controller_file_path, filename)
        end
      end

      def create_controller_files
        template "controller.rb", File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb"), @options
      end

      protected
      def available_views
        %w(index edit show new)
      end
    end
  end
end
