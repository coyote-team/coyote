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

  # @return [Integer] total number of resources owned by the organization
  def organization_resource_count
    organization.resources.size
  end

  # @return [Integer] total number of representations owned by the organization
  def organization_representation_count
    organization.representations.size
  end

  # @return [Integer] total number of represented resources owned by the organization
  def organization_represented_resource_count
    organization.resources.represented.size
  end

  # @return [Integer] total number of approved representations owned by the organization
  def organization_approved_representation_count
    organization.representations.approved.size
  end

  # @return [Integer] total number of resources that have been assigned to a user for representation, which are as-yet-unrepresented
  def organization_open_assignment_count
    organization.resources.assigned_unrepresented.size
  end

  # @return [Integer] total number of resources that are unrepresented and have not been assigned to a user for representation
  def organization_unassigned_unrepresented_count
    organization.resources.unassigned_unrepresented.size
  end

  # @return [Integer] total number of ready-to-review representations owned by the organization
  def organization_ready_to_review_count
    organization_ready_to_review_queue.size
  end

  # @return [Integer] total number of unrepresented resources owned by the organization
  def organization_unrepresented_count
    organization_unrepresented_queue.size
  end

  # @return [Integer] total number of resources owned by the organization which have been assigned to a user for representation
  def organization_assigned_count
    organization.resources.assigned.size
  end

  # Identifies the time when the most recently-created resource was added to the database, if any have been created
  # @return (see resource.latest_timestamp)
  def organization_latest_resource_timestamp
    organization.resources.latest_timestamp
  end

  # @return [Integer] total number of resources owned by the organization which have not been assigned to a user for representation
  def organization_unassigned_count
    organization_unassigned_queue.size
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
  # @note
  #   You can control how many items are shown from the queue via the Rails.configuration.x.dashboard_top_items_queue_size setting in config/application.rb
  def organization_top_unrepresented_items_queue
    organization_unrepresented_queue.first(top_items_queue_size)
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
  # @note (see #organization_top_unrepresented_items_queue)
  def organization_top_unassigned_items_queue
    organization_unassigned_queue.first(top_items_queue_size)
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
  # @note (see #organization_top_unrepresented_items_queue)
  def organization_top_ready_to_review_items_queue
    organization_ready_to_review_queue.first(top_items_queue_size)
  end

  # @return [Integer] total number of resources represented by the current user
  def current_user_represented_resources_count
    current_user.resources.represented.size
  end

  # @return [Integer] total number of representations written by the current user
  def current_user_representation_count
    current_user.representations.size
  end

  # @return [Integer] total number of approved representations written by the current user
  def current_user_approved_representation_count
    current_user.representations.approved.size
  end

  # @return [Integer] total number of unapproved representations written by the current user
  def current_user_unapproved_representation_count
    current_user.representations.not_approved.size
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
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
  
  def organization_unrepresented_queue
    organization.resources.unrepresented
  end

  def organization_unassigned_queue
    organization.resources.unassigned
  end

  def organization_ready_to_review_queue
    organization.representations.ready_to_review
  end

  def current_user_assigned_items_queue
    current_user.assigned_resources.unrepresented
  end
end
