require 'uri'
module BookmarkletHelper
  #via https://coderwall.com/p/pinqyw/create-dynamic-bookmarklets-with-ruby
  def get_bookmarklet(file, hash)
    js = File.open( "#{Rails.root}/app/assets/javascripts/#{file}", 'r' ).read
    js.gsub!( /\/\*.+?\*\/|\/\/.*(?=[\n\r])/, '' )
    js.gsub!( /s{\t}{ }gm/, '' )
    js.gsub!( /s{ +}{ }gm/, '' )         
    js.gsub!( /s{^\s+}{}gm/, '' )        
    js.gsub!( /s{\s+$}{}gm/, '' )
    js.gsub!( /s{\n}{}gm/, '' )

    hash.each_pair do |k,v|
      js.gsub!( "{{#{k.to_s}}}", v )
    end

    js = URI.escape(js)
    "javascript:(function(){#{js}}());"
  end
end
