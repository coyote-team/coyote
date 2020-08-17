# frozen_string_literal: true

module ImportHelper
  def import_column_mapping(mapping)
    return not_applicable("Not mapped") if mapping.blank?
    model = mapping.split(":").first
    model = model.constantize
    model_name = model.human_name(capitalize: true)

    column_label = valid_import_columns.find { |label, other_mapping| other_mapping == mapping }.first
    "#{model_name} → #{column_label}"
  end

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
        name,
        "#{ResourceGroup}:#{column}",
      ])
    end

    @valid_import_columns
  end
end
