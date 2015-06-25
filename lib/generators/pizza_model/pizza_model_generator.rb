require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    class PizzaModelGenerator < ActiveRecord::Generators::ModelGenerator
      source_root File.expand_path("../templates", __FILE__)
      class_option :attachments, :type => :boolean, default: false, aliases: "-a"
      class_option :sortable, type: :boolean, default: false
      def create_migration_file # fix path for migration template
        migration_template "../templates/create_table_migration.rb", "db/migrate/create_#{table_name}.rb"
      end
      
    end
  end
end