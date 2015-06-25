require 'rails/generators/rails/resource_route/resource_route_generator'

module Rails
  module Generators
    class PizzaRouteGenerator < ResourceRouteGenerator
      class_option :sortable, type: :boolean, default: false

      def add_resource_route
        return if options[:actions].present?

        # iterates over all namespaces and opens up blocks
        regular_class_path.each_with_index do |namespace, index|
          write("namespace :#{namespace} do", index + 1)
        end

        # inserts the primary resource

        
        write("resources :#{file_name.pluralize} do", route_length + 1)
        
        if options[:sortable]
          write("post :sort, on: :collection", route_length + 2)
        end
        
        write("end", route_length + 1)

        # ends blocks
        regular_class_path.each_index do |index|
          write("end", route_length - index)
        end

        # route prepends two spaces onto the front of the string that is passed, this corrects that
        route route_string[2..-1]
      end
    end
  end
end
