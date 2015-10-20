class HomeController < ApplicationController
  before_action :prep_assign_to

  def index
    if current_user
      limit = 10

      #TODO move parts  of this into the model and view...
      
      my_images = current_user.images

      @my_queue = my_images.collect{|i| i if i.undescribed_by?(current_user)}.compact
      @my_queue_count = @my_queue.count
      @my_queue = @my_queue.first(limit)

      @my_description_ids = current_user.descriptions.map{|d| d.id}

      #leaderboard
      @my_described_count = my_images.collect{|i| i if i.described_by?(current_user)}.compact.length
      @my_completed_count= my_images.collect{|i| i if i.completed_by?(current_user)}.compact.length
      @my_descriptions_count= @my_description_ids.length

      if current_user.admin?
        @unassigned_count = Image.unassigned.count
        @unassigned = Image.unassigned.first(limit)
        @undescribed_count = Image.undescribed.count
        @undescribed = Image.undescribed.first(limit)

        @ready_to_review = Description.ready_to_review
        @ready_to_review_count = @ready_to_review.count
        @ready_to_review = @ready_to_review.first(limit).collect{|d| d.image}.uniq
        #@not_approved = images.collect{|i| i if i.not_approved?}.compact.first(limit)
        
        #leaderboard
        images = Image.all
        @described_count = images.described.length
        #@incomplete_count = images.collect{|i| i unless i.completed?}.compact.length
        #@assigned_count = images.assigned.length
        @description_count = Description.all.count
      end
    end
  end
end
