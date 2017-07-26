# frozen_string_literal: true

module Coyote
  # Namespace for site/CMS-specific Coyote code
  # @see Coyote::Strategies::MCA
  module Strategies
    module_function

    # @return [Array<Class>] a list of all strategy classes
    def all
      constants.map do |constant_name| 
        const_get(constant_name)
      end
    end
  end
end

# Eager-load all strategies so WebsitesController can see them
Pathname.glob("./lib/coyote/strategies/*.rb").each do |path|
  require_dependency path.sub_ext("") 
end
