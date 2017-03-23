class HomeController < ApplicationController
  before_action :get_users
  before_action :admin, only: [:deploy]

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
        check_commit
        @review_count = Description.ready_to_review.count
        #@unapproved_count = Description.not_approved.count
        @open_assignment_count = Image.assigned_undescribed.count
        @unassigned_undescribed_count = Image.unassigned_undescribed.count
        @latest_image_timestamp = nil
        latest_image = Image.except(:order).order(created_at: :desc).first
        @latest_image_timestamp = latest_image.created_at if latest_image
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

  def deploy
    @deployed_at = Rails.cache.fetch("deployed_at", expires_in: 5.minutes) do 
      pid = spawn("bin/deploy_self.sh #{Rails.env}")
      Process.detach(pid)
      Time.now
    end
    Rails.logger.info "Deploying"
    render nothing: true
  end

  protected
  def check_commit
    @current_commit = Rails.cache.fetch("current_commit", expires_in: 5.minutes) do 
      if Rails.env.development?
        `git rev-parse --short HEAD`.chomp
      else
        `cat REVISION`.first(7)
      end
    end
    @latest_commit = Rails.cache.fetch("latest_commit", expires_in: 5.minutes) do 
      require 'open-uri'
      builds = JSON.load(open("https://api.travis-ci.org/repos/coyote-team/coyote/builds.json"))
      builds = builds.map{|b| b if  b["result"]==0}.compact
      builds[0]["commit"].first(7)
    end
    @deployed_at = Rails.cache.read("deployed_at")
  end
end
