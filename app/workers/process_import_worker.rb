# frozen_string_literal: true

class ProcessImportWorker
  include Cloudtasker::Worker

  attr_reader :import

  def perform(id)
    @import = Import.find(id)

    successes, failures = 0, 0
    @import.read_sheets.each do |sheet|
      Import.transaction do
        sheet_successes, sheet_failures = import_sheet(sheet)
        successes += sheet_successes
        failures += sheet_failures
      end
    end

    @import.update_columns(
      failures:  failures,
      successes: successes,
      status:    successes.zero? ? :import_failed : :imported,
    )
  rescue => error
    @import.update_columns(
      error:  error.message,
      status: :import_failed,
    )
  end

  private

  def find_user_named(name)
    name = name.split(" ").map(&:strip).join(" ")
    organization.users.where("CONCAT(first_name, ' ', last_name) = ?", name).first
  end

  def import_sheet(sheet)
    # Loop throw each row of the sheet so we can build resources from it
    successes, failures = 0, 0
    sheet.rows.each do |row|
      next if row.empty?

      pp row

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

        value = row[column_mapping.name].to_s
        next if value.blank?

        model, column = column_mapping.map_to_column.split(":")
        column = column.to_sym

        case model
        when "Metum"
          representations.push({
            metum: organization.meta.find(column.to_s),
            text:  value,
          })

        when "Resource"
          case column
          when :name
            resource_attributes[:name] = value.strip
          when :canonical_id
            resource_finder[:canonical_id] = value.strip
          when :source_uri
            resource_finder[:source_uri] = value.strip
          when :priority_flag
            resource_attributes[:priority_flag] = value.strip
          when :host_uris
            resource_attributes[:host_uris] = value.strip
          end

        when "Representation"
          # Right now we only accept one column directly on representation (author); the `text` comes in via the metum
          if column == :author
            representation_attributes[:author] = find_user_named(value.strip)
          end

        when "ResourceGroup"
          if column == :name
            resource_groups.push(ResourceGroup.find_or_initialize_by(organization_id: import.organization_id, name: value.strip))
          elsif column == :webhook_uri
            resource_group_attributes[:webhook_uri] = value.strip
          end
        end
      end

      ## Okay, we've gone through every column mapping on the row and figured out where it applies - let's create a record
      # First, resource groups (since they'll be assigned to the resource)
      resource_groups.each do |resource_group|
        resource_group.update!(resource_group_attributes)
      end
      resource_attributes[:resource_groups] = resource_groups

      # Next, find or create the resource and assign the resource groups
      resource = organization.resources.find_or_initialize_by_canonical_id_or_source_uri(resource_finder)
      resource.update!(resource_finder.merge(resource_attributes))

      # Finally, find or create representations using the resource's "sane defaults" logic
      representations_attributes = representations.map { |representation|
        representation.merge(representation_attributes)
      }
      resource.update!(representations_attributes: representations_attributes)
      successes += 1
    rescue
      failures += 1
    end

    [successes, failures]
  end

  def organization
    import.organization
  end
end
