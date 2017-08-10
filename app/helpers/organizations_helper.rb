module OrganizationsHelper
  def image_count(count)
    "#{number_with_delimiter(count)} #{'image'.pluralize(count)}"
  end

  def description_count(count)
    "#{number_with_delimiter(count)} #{'description'.pluralize(count)}"
  end

  # @see http://guides.rubyonrails.org/layouts_and_rendering.html#passing-local-variables
  def progress_bar_attributes(local_vars)
    { :"aria-valuemax" => progress_max(local_vars), 
      :"aria-valuemin" => progress_min(local_vars), 
      :"aria-valuenow" => progress_val(local_vars), 
      :role => "progressbar", 
      :style => "width: #{progress_bar_percentage(local_vars)}%" }
  end

  def progress_bar_percentage(local_vars)
    max   = progress_max(local_vars)
    value = progress_val(local_vars)
    percentage = 100 * (value / max.to_f)
    number_to_percentage(percentage,precision: 0)
  end

  def progress_label(local_vars)
    value = progress_val(local_vars)
    title = progress_title(local_vars)
    "#{number_with_delimiter(value)} #{title}"
  end

  private

  def progress_title(vars)
    vars.fetch(:title,"?")
  end

  def progress_max(vars)
    vars.fetch(:max,1)
  end

  def progress_min(vars)
    vars.fetch(:min,0)
  end

  def progress_val(vars)
    vars.fetch(:value,0)
  end
end
