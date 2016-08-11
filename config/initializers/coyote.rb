Dir["#{Rails.root}/lib/coyote/*.rb"].each {|file| require file }
Dir["#{Rails.root}/lib/coyote/strategies/*.rb"].each {|file| require file }

