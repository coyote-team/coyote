class HomeController < ApplicationController
  def index
    if current_user
      #TODO should only show my content descriptions for these two
      limit = 10
      @my_queue = current_user.images.collect{|i| i if i.undescribed_by?(current_user)}.compact
      @my_queue_count = @my_queue.count
      @my_queue = @my_queue.first(limit)
      #@my_described_queue = current_user.images.collect{|i| i if i.described_by?(current_user)}.compact.first(limit)
      #@my_completed_queue= current_user.images.collect{|i| i if i.completed_by?(current_user)}.compact.first(limit)
      @my_description_ids = current_user.descriptions.map{|d| d.id}

      if current_user.admin?
        @users = User.all
        @unassigned_count = Image.unassigned.count
        @unassigned = Image.unassigned.first(limit)
        @undescribed_count = Image.undescribed.count
        @undescribed = Image.undescribed.first(limit)
        #@assigned = images.assigned.first(limit)
        #@completed = images.collect{|i| i if i.completed?}.compact.first(limit)
        #@incomplete = images.collect{|i| i unless i.completed?}.compact.first(limit)
        @ready_to_review = Description.ready_to_review
        @ready_to_review_count = @ready_to_review.count
        @ready_to_review = @ready_to_review.first(limit).collect{|d| d.image}.uniq
        #@not_approved = images.collect{|i| i if i.not_approved?}.compact.first(limit)
      end
    end
  end
end
