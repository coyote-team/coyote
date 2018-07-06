module ScavengerHunt
  class Engine < ::Rails::Engine
    isolate_namespace ScavengerHunt
    config.assets.paths << root.join('node_modules')
  end
end
