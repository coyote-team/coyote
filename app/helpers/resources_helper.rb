# View methods for displaying resources
module ResourcesHelper
  def context_list
    current_user.contexts.map do |c|
      [c.title,c.id]
    end
  end
end
