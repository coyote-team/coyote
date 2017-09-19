# Methods to help Websites views
module WebsitesHelper
  # @return [Array<String,String>] List of Website strategies for use in collection helpers
  # @see Coyote::Strategies#all
  def strategies_collection
    Coyote::Strategies.all.map do |s| 
      [s.title,s.name]
    end
  end
end
