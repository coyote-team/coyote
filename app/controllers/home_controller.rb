class HomeController < ApplicationController
  before_action :get_users

  def index
    if current_user
      limit = 10

      #OUR STATUS
      images = Image.all
      @image_count = images.count
      @described_count = images.described.length
      @description_count = Description.all.count
      @approved_count = Description.approved.count
      if current_user.admin?
        @review_count = Description.ready_to_review.count
        @unapproved_count = Description.not_approved.count
        @open_assignment_count = Image.assigned_undescribed.count
        @unassigned_undescribed_count = Image.unassigned_undescribed.count
        @latest_image_timestamp = Image.recent.first.created_at
      end

      #MY STATUS
      my_descriptions = current_user.descriptions
      @my_description_count = my_descriptions.count
      @my_approved_count = my_descriptions.approved.count
      @my_ready_to_review_count = my_descriptions.ready_to_review.count
      @my_unapproved_count = my_descriptions.not_approved.count

      #QUEUES
      my_images = current_user.images
      @my_images_count = my_images.count
      @my_queue = my_images.collect{|i| i if i.undescribed_by?(current_user)}.compact
      @my_queue_count = @my_queue.count
      @my_queue = @my_queue.first(limit)
      @my_description_ids = current_user.descriptions.map{|d| d.id}

      if current_user.admin?
        @unassigned_count = Image.unassigned.count
        @assigned_count = @image_count - @unassigned_count
        @unassigned = Image.unassigned.first(limit)

        @undescribed_count = Image.undescribed.count
        @undescribed = Image.undescribed.first(limit)

        @ready_to_review = Description.ready_to_review
        @ready_to_review_count = @ready_to_review.count
        @ready_to_review = @ready_to_review.first(limit).collect{|d| d.image}.uniq
      end
    else
    end
    @minimum_password_length = User.password_length.min
  end
end
