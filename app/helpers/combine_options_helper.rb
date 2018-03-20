module CombineOptionsHelper
  def combine_options(options, defaults)
    defaults.each_key do |key|
      options[key] =
        case defaults[key]
        when Hash
          combine_options(options[key] || {}, defaults[key])
        else
          [defaults[key], options[key]].flatten.join(" ").strip
        end
    end
    options
  end
end
