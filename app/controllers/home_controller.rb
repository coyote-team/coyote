class HomeController < ApplicationController
  def index
    @user = current_user #spoof current user for view
    if current_user
      #TODO should only show my content descriptions for these two
      @my_queue = current_user.images.collect{|i| i if i.undescribed_by?(current_user)}.compact
      @my_described_queue = current_user.images.collect{|i| i if i.described_by?(current_user)}.compact
      @my_completed_queue= current_user.images.collect{|i| i if i.completed_by?(current_user)}.compact
      @my_description_ids = current_user.descriptions.map{|d| d.id}

      if current_user.admin?
        images = Image.all
        @unassigned = images.unassigned 
        @assigned = images.assigned 
        @completed = @assigned.collect{|i| i if i.completed?}.compact
        @incomplete = @assigned.collect{|i| i unless i.completed?}.compact
        @ready_to_review = @assigned.collect{|i| i if i.ready_to_review?}.compact
        @not_approved = @assigned.collect{|i| i if i.not_approved?}.compact
      end
    end
  end
end
