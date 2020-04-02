# frozen_string_literal: true

module OrganizationsHelper
  # @param local_vars [Hash] passed to the partial as "local assigns"; lets our templates optionally specify certain parameters
  # @return [Hash] aria and style attributes for drawing a progress bar
  # @see http://guides.rubyonrails.org/layouts_and_rendering.html#passing-local-variables
  def progress_bar_attributes(local_vars)
    {"aria-valuemax": progress_max(local_vars),
     "aria-valuemin": progress_min(local_vars),
     "aria-valuenow": progress_val(local_vars),
     role:            "progressbar",
     style:           "width: #{progress_bar_percentage(local_vars)}%"}
  end

  # @param (see progress_bar_attributes)
  # @return [String] formatted progress percentage of value vs max
  def progress_bar_percentage(local_vars)
    max = progress_max(local_vars)
    return "" if max.zero?

    value = progress_val(local_vars)
    percentage = 100 * (value / max.to_f)
    number_to_percentage(percentage, precision: 0)
  end

  # @param title [String] string to use for the label
  # @param value [Integer] numerical value for the label
  def progress_label(title, value)
    "#{number_with_delimiter(value)} #{title}"
  end

  # @param count [Integer]
  # @return [String] formatted number of representations, with correct pluralization
  def representation_count(count)
    "#{number_with_delimiter(count)} #{"representation".pluralize(count)}"
  end

  # @param count [Integer]
  # @return [String] formatted number of images, with correct pluralization
  def resource_count(count)
    "#{number_with_delimiter(count)} #{"resource".pluralize(count)}"
  end

  private

  def progress_max(vars)
    vars.fetch(:max, 1)
  end

  def progress_min(vars)
    vars.fetch(:min, 0)
  end

  def progress_val(vars)
    vars.fetch(:value, 0)
  end
end
