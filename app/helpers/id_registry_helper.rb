# frozen_string_literal: true

# IDRegistryHelper ensures no ID's overlap on the page by keeping track of
# those that have been generated and providing iterations to them as things
# move forward
module IdRegistryHelper
  def id_for(object)
    string = if object.respond_to?(:model_name)
      "#{object.model_name.singular}-#{object.to_param || "new"}"
    else
      object.to_s
    end
    original_id = id = string.to_s.parameterize
    i = 0
    while ids.include? id
      i = i.succ
      id = "#{original_id}-#{i}"
    end
    ids.add(id)
    id
  end

  def ids
    @ids ||= Set.new
  end
end
