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
        #@unapproved_count = Description.not_approved.count
        @open_assignment_count = Image.assigned_undescribed.count
        @unassigned_undescribed_count = Image.unassigned_undescribed.count
        @latest_image_timestamp = Image.except(:order).order(created_at: :desc).first.created_at
      end

      #YOUR STATUS
      your_descriptions = current_user.descriptions
      @your_described_count = current_user.descriptions.collect{|d| d if d.user == current_user}.compact.count
      @your_approved_count = your_descriptions.approved.count
      #@your_ready_to_review_count = your_descriptions.ready_to_review.count
      @your_unapproved_count = your_descriptions.not_approved.count

      #QUEUES
      your_images = current_user.images
      #@your_images_count = your_images.count
      @your_queue = your_images.collect{|i| i if i.undescribed_by?(current_user)}.compact
      @your_queue_count = @your_queue.count
      @your_queue = @your_queue.first(limit)
      @your_description_ids = current_user.descriptions.map{|d| d.id}

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
