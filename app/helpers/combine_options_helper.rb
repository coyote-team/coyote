# frozen_string_literal: true

module CombineOptionsHelper
  def combine_options(options, defaults)
    defaults.each_key do |key|
      options[key] =
        case defaults[key]
        when Hash
          combine_options(options[key] || {}, defaults[key])
        when String, Symbol
          [defaults[key], options[key]].flatten.join(" ").strip
        when Array
          defaults[key] + Array(options[key])
        else
          defaults[key]
        end
    end
    options
  end
end
