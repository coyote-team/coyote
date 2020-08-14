# frozen_string_literal: true

module ImportHelper
  def valid_import_columns
    return @valid_import_columns if defined? @valid_import_columns

    @valid_import_columns = []
    Import::RESOURCE_IMPORT_COLUMNS.each do |name, column|
      @valid_import_columns.push([
        name,
        "#{Resource}:#{column}",
      ])
    end

    current_organization.meta.each do |metum|
      @valid_import_columns.push([
        "#{metum.name} Text",
        "#{Metum}:#{metum.id}",
      ])
    end

    Import::REPRESENTATION_IMPORT_COLUMNS.each do |name, column|
      @valid_import_columns.push([
        name,
        "#{Representation}:#{column}",
      ])
    end

    Import::RESOURCE_GROUP_IMPORT_COLUMNS.each do |name, column|
      @valid_import_columns.push([
        "#{ResourceGroup.model_name.human.titleize} #{name}",
        "#{ResourceGroup}:#{column}",
      ])
    end

    @valid_import_columns
  end
end
