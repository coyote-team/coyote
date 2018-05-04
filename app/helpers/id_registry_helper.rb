# IDRegistryHelper ensures no ID's overlap on the page by keeping track of
# those that have been generated and providing iterations to them as things
# move forward
module IdRegistryHelper
  def ids
    @ids ||= Set.new
  end

  def id_for(string)
    original_id = id = string.parameterize
    i = 0
    while ids.include? id
      i = i.succ
      id = "#{original_id}-#{i}"
    end
    ids.add(id)
    id
  end
end
