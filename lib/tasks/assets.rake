# frozen_string_literal: true

namespace :assets do
  task precompile: :environment do
    # This will happen AFTER the default Rails assets precompilation task. We will use this
    # opportunity to move precompiled error templates into public/ root
    root = Rails.root.join("public")
    assets = root.join("assets")

    # Remove fingerprinted and gzipped HTML files
    FileUtils.safe_unlink(Dir[assets.join("**/*.html.gz")])
    FileUtils.safe_unlink(Dir[assets.join("**/[0-9][0-9][0-9]-*.html")])

    # OKAY! Now we copy the HTML files into root
    Dir[Rails.root.join("public", "assets", "**", "*.html")].each do |file|
      FileUtils.copy(file, root.join(File.basename(file)))
    end
  end
end
