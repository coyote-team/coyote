# frozen_string_literal: true

namespace :assets do
  namespace :precompile do
    task pages: :environment do
      assets = Rails.root.join("app", "assets", "html")
      dest = Rails.root.join("public")

      files = Dir[assets.join("**", "*.html")] + Dir[assets.join("**", "*.html.*")]
      files.each do |file|
        base = File.basename(file)
        base = File.basename(base, File.extname(base)) while File.extname(base).present?

        dir = File.dirname(file)
        extless_path = Pathname.new(dir).join(base)
        content = ApplicationController.renderer.render(file: extless_path).to_str

        File.write(dest.join("#{base}.html"), content)
      end
    end
  end
end
