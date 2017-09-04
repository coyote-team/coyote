# A Plain Old Ruby Object (PORO) responsible for organizing various Organization dashboard details. Uses many scopes
# defined on Organization and User.
# @see OrganizationsController
# @see Organization
# @see User
class Dashboard
  # @param current_user [User] identifies the user for whom we are creating a dashboard
  # @param organization [Organization] Identifies the organization for which we are creating a dashboard
  def initialize(current_user,organization)
    @current_user = current_user
    @organization = organization
  end

  # @return [Integer] total number of images owned by the organization
  def organization_image_count
    organization.images.size
  end

  # @return [Integer] total number of descriptions owned by the organization
  def organization_description_count
    organization.descriptions.size
  end

  # @return [Integer] total number of described images owned by the organization
  def organization_described_image_count
    organization.images.described.size
  end

  # @return [Integer] total number of approved descriptions owned by the organization
  def organization_approved_description_count
    organization.descriptions.approved.size
  end

  # @return [Integer] total number of images that have been assigned to a user for description, which are as-yet-undescribed
  def organization_open_assignment_count
    organization.images.assigned_undescribed.size
  end

  # @return [Integer] total number of images that are undescribed and have not been assigned to a user for description
  def organization_unassigned_undescribed_count
    organization.images.unassigned_undescribed.size
  end

  # @return [Integer] total number of ready-to-review descriptions owned by the organization
  def organization_ready_to_review_count
    organization_ready_to_review_queue.size
  end

  # @return [Integer] total number of undescribed images owned by the organization
  def organization_undescribed_count
    organization_undescribed_queue.size
  end

  # @return [Integer] total number of images owned by the organization which have been assigned to a user for description
  def organization_assigned_count
    organization.images.assigned.size
  end

  # Identifies the time when the most recently-created image was added to the database, if any have been created
  # @return (see Image.latest_timestamp)
  def organization_latest_image_timestamp
    organization.images.latest_timestamp
  end

  # @return [Integer] total number of images owned by the organization which have not been assigned to a user for description
  def organization_unassigned_count
    organization_unassigned_queue.size
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important images assigned to the user for description
  # @note
  #   You can control how many items are shown from the queue via the Rails.configuration.x.dashboard_top_items_queue_size setting in config/application.rb
  def organization_top_undescribed_items_queue
    organization_undescribed_queue.first(top_items_queue_size)
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important images assigned to the user for description
  # @note (see #organization_top_undescribed_items_queue)
  def organization_top_unassigned_items_queue
    organization_unassigned_queue.first(top_items_queue_size)
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important images assigned to the user for description
  # @note (see #organization_top_undescribed_items_queue)
  def organization_top_ready_to_review_items_queue
    organization_ready_to_review_queue.first(top_items_queue_size)
  end

  # @return [Integer] total number of images described by the current user
  def current_user_described_images_count
    current_user.images.described.size
  end

  # @return [Integer] total number of descriptions written by the current user
  def current_user_description_count
    current_user.descriptions.size
  end

  # @return [Integer] total number of approved descriptions written by the current user
  def current_user_approved_description_count
    current_user.descriptions.approved.size
  end

  # @return [Integer] total number of unapproved descriptions written by the current user
  def current_user_unapproved_description_count
    current_user.descriptions.not_approved.size
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important images assigned to the user for description
  # @note (see #organization_ready_to_review)
  def current_user_top_assigned_items_queue
    current_user_assigned_items_queue.first(top_items_queue_size)
  end

  # @return [Integer] total number of items assigned to the user
  def current_user_assigned_items_count
    current_user_assigned_items_queue.size
  end

  # @return [Boolean] whether or not the user has any assigned items
  def current_user_queue_empty?
    current_user_assigned_items_queue.empty?
  end

  # @return [ActiveRecord::Associations::CollectionProxy] all of the users in the organization
  def organization_users
    organization.users.sorted
  end

  private

  attr_reader :current_user, :organization

  def top_items_queue_size
    Rails.configuration.x.dashboard_top_items_queue_size
  end
  
  def organization_undescribed_queue
    organization.images.undescribed.prioritized
  end

  def organization_unassigned_queue
    organization.images.unassigned.prioritized
  end

  def organization_ready_to_review_queue
    organization.descriptions.ready_to_review
  end

  def current_user_assigned_items_queue
    current_user.assigned_images.undescribed.prioritized
  end
end
