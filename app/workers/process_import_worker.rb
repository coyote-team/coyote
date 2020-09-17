# frozen_string_literal: true

class ProcessImportWorker
  include Cloudtasker::Worker

  attr_reader :import

  def perform(id)
    @import = Import.find(id)

    result = new_result_set
    @import.read_sheets.each do |sheet|
      Import.transaction do
        sheet_result = import_sheet(sheet)
        sheet_result.each do |key, value|
          result[key] += value
        end
      end
    end

    if result[:successes].zero?
      result[:status] = :import_failed
      result[:error] = "No resources were created or updated"
    else
      result[:status] = :imported
      result[:error] = nil
    end
    @import.update_columns(result)
  rescue => error
    @import.update_columns(
      error:  error.message,
      status: :import_failed,
    )
  end

  private

  def convert_to_representation_status(status)
    Representation.statuses[status.underscore.singularize]
  end

  def find_user_named(name)
    name = name.split(" ").map(&:strip).join(" ")
    organization.users.where("CONCAT(first_name, ' ', last_name) = ?", name).first
  end

  def import_sheet(sheet)
    # Loop throw each row of the sheet so we can build resources from it
    result = new_result_set
    sheet.rows.each do |row|
      next if row.empty?

      # Set up conditions to find_or_initialize a resource for this row
      resource_finder = {}
      resource_attributes = {}.with_indifferent_access

      # Prepare to find or create resource groups for this resource, too
      resource_groups = []
      resource_group_attributes = {}.with_indifferent_access

      # Prepare to load the resource up with representations
      representations = []
      representation_attributes = {language: "en"}.with_indifferent_access

      # Now we'll look at each column and how it maps to resources
      sheet.columns.each do |column_mapping|
        next if column_mapping.map_to_column.blank?

        value = row[column_mapping.name].to_s.strip
        next if value.blank?

        model, column = column_mapping.map_to_column.split(":")
        column = column.to_sym

        case model
        when "Metum"
          case column
          when :new
            representations.push({
              metum: organization.meta.find_or_initialize_by(name: column.to_s) { |metum| metum.skip_instructions = true },
              text:  value,
            })
          else
            representations.push({
              metum: organization.meta.find(column.to_s),
              text:  value,
            })
          end

        when "Resource"
          case column
          when :name
            resource_attributes[:name] = value
          when :canonical_id
            resource_finder[:canonical_id] = value
          when :source_uri
            resource_finder[:source_uri] = value
          when :priority_flag
            resource_attributes[:priority_flag] = value
          when :host_uris
            resource_attributes[:host_uris] = value
          end

        when "Representation"
          # Right now we only accept one column directly on representation (author); the `text` comes in via the metum
          case column
          when :author
            representation_attributes[:author] = find_user_named(value)
          when :status
            status = convert_to_representation_status(value)
            representation_attributes[:status] = status if status.present?
          end

        when "ResourceGroup"
          case column
          when :name
            resource_groups.push(ResourceGroup.find_or_initialize_by(organization_id: import.organization_id, name: value))
          when :webhook_uri
            resource_group_attributes[:webhook_uri] = value
          end
        end
      end

      ## Okay, we've gone through every column mapping on the row and figured out where it applies - let's create a record
      # First, resource groups (since they'll be assigned to the resource)
      resource_groups.each do |resource_group|
        resource_group.update!(resource_group_attributes)
      end
      resource_attributes[:resource_groups] = resource_groups if resource_groups.any?

      # Next, find or create the resource and assign the resource groups
      resource = organization.resources.find_or_initialize_by_canonical_id_or_source_uri(resource_finder)
      resource.assign_attributes(resource_finder.merge(resource_attributes))
      was_new = resource.new_record?
      was_changed = !was_new && resource.changes.any?

      resource.save!

      # Finally, find or create representations using the resource's "sane defaults" logic
      representations_attributes = representations.map { |representation|
        representation.merge(representation_attributes)
      }
      resource.update!(representations_attributes: representations_attributes)
      result[:successes] += 1

      # Record what we changed when we ran this import
      if was_new
        result[:new_records] += 1
      elsif was_changed
        result[:changed_records] += 1
      else
        result[:duplicate_records] += 1
      end

    rescue
      # Record a failure and continue to the next row
      result[:failures] += 1
    end

    result
  end

  def new_result_set
    {
      successes:         0,
      failures:          0,
      new_records:       0,
      duplicate_records: 0,
      changed_records:   0,
    }
  end

  def organization
    import.organization
  end
end
