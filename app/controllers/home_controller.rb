class HomeController < ApplicationController
  def index
    @user = current_user #spoof current user for view
    if current_user
      #TODO should only show my content descriptions for these two
      limit = 10
      @my_queue = current_user.images.collect{|i| i if i.undescribed_by?(current_user)}.compact.first(limit)
      @my_described_queue = current_user.images.collect{|i| i if i.described_by?(current_user)}.compact.first(limit)
      @my_completed_queue= current_user.images.collect{|i| i if i.completed_by?(current_user)}.compact.first(limit)
      @my_description_ids = current_user.descriptions.map{|d| d.id}

      if current_user.admin?
        images = Image.all
        @unassigned = images.unassigned.first(limit)
        @assigned = images.assigned.first(limit)
        @completed = @assigned.collect{|i| i if i.completed?}.compact.first(limit)
        @incomplete = @assigned.collect{|i| i unless i.completed?}.compact.first(limit)
        @ready_to_review = @assigned.collect{|i| i if i.ready_to_review?}.compact.first(limit)
        @not_approved = @assigned.collect{|i| i if i.not_approved?}.compact.first(limit)
      end
    end
  end
end
