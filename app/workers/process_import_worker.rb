# frozen_string_literal: true

class ProcessImportWorker < ApplicationWorker
  ROWS_PER_IMPORT = 10

  attr_reader :import

  def perform(id, sheet_index = 0, row_index = 0)
    @import = Import.find(id)

    # Require a sheet to import. Assume we're importing the first sheet starting at row "0".
    sheets = import.read_sheets
    sheet = sheets[sheet_index]
    return if sheet.blank?

    # Convert indices to usable row ranges, e.g. sheet_index = 1 would yield rows 200 through 400
    rows = sheet.rows[row_index, ROWS_PER_IMPORT]

    # Run the import on just those rows and update the import to reflect the most recent chunk
    result = import_rows(rows, sheet: sheet)
    import.update_columns(result)

    # Okay, here's where it gets interesting - look ahead to see if there's more rows on this sheet
    # or more sheets in the workbook
    if sheet.rows.length > row_index + ROWS_PER_IMPORT
      # There are more rows in this, e.g. row_index = 1, we just fetched 200 + 200, or 400 - so if there are 401, we'll need to fetch from row_index = 400, e.g. 400-600
      self.class.perform_async(id, sheet_index, row_index + ROWS_PER_IMPORT)
    elsif sheets.length > sheet_index + 1
      # There are no more rows, but there are more sheets
      self.class.perform_async(id, sheet_index.succ, 0)
    elsif import.successes.zero?
      import.update(
        status: :import_failed,
        error:  "No resources were created or updated",
      )
    else
      import.update(
        status: :imported,
        error:  nil,
      )
    end
  rescue => error
    import.update_columns(
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

  def import_rows(rows, sheet:)
    # Loop throw each row of the sheet so we can build resources from it
    result = new_result_set

    rows.each do |row|
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

    rescue => error
      Rails.logger.warn "[IMPORT ERROR]: Could not import #{row.inspect}: #{error.inspect}"
      # Record a failure and continue to the next row
      result[:failures] += 1
    end

    result
  end

  def new_result_set
    {
      successes:         import.successes,
      failures:          import.failures,
      new_records:       import.new_records,
      duplicate_records: import.duplicate_records,
      changed_records:   import.changed_records,
    }
  end

  def organization
    import.organization
  end
end
