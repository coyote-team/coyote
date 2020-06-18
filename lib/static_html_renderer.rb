# frozen_string_literal: true

class StaticHTMLRenderer
  # Render static HTML from Slim using the standard Sprockets context
  def self.call(input)
    context = input[:environment].context_class.new(input)

    basename = File.basename(input[:filename])
    basename = File.basename(basename, File.extname(basename)) while File.extname(basename).present?

    dirname = File.dirname(input[:filename])
    filename = "#{dirname}/#{basename}"

    data = ApplicationController.renderer.render(file: filename).to_str
    context.metadata.merge(data: data)
  end
end
