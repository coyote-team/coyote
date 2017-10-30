# View methods for displaying resources
module ResourcesHelper
  def scope_search_collection
    Resource.ransackable_scopes.map do |scope_name|
      [scope_name.to_s.titleize.split(/\s+/).join(' &amp; ').html_safe,scope_name]
    end
  end

  def context_list
    current_user.contexts.map do |c|
      [c.title,c.id]
    end
  end
end
