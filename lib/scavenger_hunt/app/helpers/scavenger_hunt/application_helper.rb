module ScavengerHunt
  module ApplicationHelper
    # TODO: Extract the component libraries out to a separate a11y library and
    # make it a dependency of both Coyote and Scavenger Hunt
    include ComponentHelper
    include CombineOptionsHelper
    include IdRegistryHelper
    include TitleHelper
    include ToolbarHelper

    def body_class(*classnames)
      @body_class ||= []
      @body_class.push(*classnames)
    end
  end
end
