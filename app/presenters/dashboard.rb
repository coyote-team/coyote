# frozen_string_literal: true

# A Plain Old Ruby Object (PORO) responsible for organizing various Organization dashboard details. Uses many scopes
# defined on Organization and User.
# @see OrganizationsController
# @see Organization
# @see User
class Dashboard
  # @param current_user [User] identifies the user for whom we are creating a dashboard
  # @param organization [Organization] Identifies the organization for which we are creating a dashboard
  def initialize(current_user, organization)
    @current_user = current_user
    @organization = organization
  end

  # @return [Integer] total number of approved representations written by the current user
  def current_user_approved_representation_count
    current_user.authored_representations.approved.count
  end

  # @return [Integer] total number of items assigned to the user
  def current_user_assigned_items_count
    current_user_assigned_items_queue.count
  end

  # @return [Itnger] total number of resources assigned to the user which do not have a representation
  def current_user_open_assignments_count
    current_user.assigned_resources.in_organization(@organization).unrepresented.count
  end

  # @return [Boolean] whether or not the user has any assigned items
  def current_user_queue_empty?
    current_user_assigned_items_queue.empty?
  end

  # @return [Integer] total number of representations written by the current user
  def current_user_representation_count
    current_user.authored_representations.count
  end

  # @return [Integer] total number of resources represented by the current user
  def current_user_represented_resources_count
    current_user.resources.represented_by(current_user).count
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
  # @note (see #organization_ready_to_review)
  def current_user_top_assigned_items_queue
    current_user_assigned_items_queue.first(top_items_queue_size)
  end

  # @return [Integer] total number of unapproved representations written by the current user
  def current_user_unapproved_representation_count
    current_user.authored_representations.not_approved.count
  end

  # @return [Integer] total number of approved representations owned by the organization
  def organization_approved_representation_count
    organization.representations.approved.count
  end

  # @return [Integer] total number of resources owned by the organization which have been assigned to a user for representation
  def organization_assigned_count
    organization.resources.assigned.count
  end

  # Identifies the time when the most recently-created resource was added to the database, if any have been created
  # @return (see resource.latest_timestamp)
  def organization_latest_resource_timestamp
    organization.resources.latest_timestamp
  end

  # @return [Integer] total number of resources that have been assigned to a user for representation, which are as-yet-unrepresented
  def organization_open_assignment_count
    organization.resources.assigned_unrepresented.count
  end

  # @return [Integer] total number of ready-to-review representations owned by the organization
  def organization_ready_to_review_count
    organization_ready_to_review_queue.count
  end

  # @return [Integer] total number of representations owned by the organization
  def organization_representation_count
    organization.representations.count
  end

  # @return [Integer] total number of represented resources owned by the organization
  def organization_represented_resource_count
    organization.resources.represented.count
  end

  # @return [Integer] total number of resources owned by the organization
  def organization_resource_count
    organization.resources.count
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
  # @note (see #organization_top_unrepresented_items_queue)
  def organization_top_ready_to_review_items_queue
    organization_ready_to_review_queue.first(top_items_queue_size)
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
  # @note (see #organization_top_unrepresented_items_queue)
  def organization_top_unassigned_items_queue
    organization_unassigned_queue.first(top_items_queue_size)
  end

  # @return [ActiveRecord::Associations::CollectionProxy] a subset of the most important resources assigned to the user for representation
  # @note
  #   You can control how many items are shown from the queue via the Rails.configuration.x.dashboard_top_items_queue_size setting in config/application.rb
  def organization_top_unrepresented_items_queue
    organization_unrepresented_queue.first(top_items_queue_size)
  end

  # @return [Integer] total number of unapproved representations owned by the organization
  def organization_unapproved_representation_count
    organization.representations.not_approved.count
  end

  # @return [Integer] total number of resources owned by the organization which have not been assigned to a user for representation
  def organization_unassigned_count
    organization_unassigned_queue.count
  end

  # @return [Integer] total number of resources that are unrepresented and have not been assigned to a user for representation
  def organization_unassigned_unrepresented_count
    organization.resources.unassigned_unrepresented.count
  end

  # @return [Integer] total number of unrepresented resources owned by the organization
  def organization_unrepresented_count
    organization_unrepresented_queue.count
  end

  # @return [ActiveRecord::Associations::CollectionProxy] all of the users in the organization
  def organization_users
    organization.users.sorted
  end

  private

  attr_reader :current_user, :organization

  def current_user_assigned_items_queue
    current_user.assigned_resources.in_organization(@organization).unrepresented
  end

  def organization_ready_to_review_queue
    organization.representations.ready_to_review
  end

  def organization_unassigned_queue
    organization.resources.unassigned
  end

  def organization_unrepresented_queue
    organization.resources.unrepresented
  end

  def top_items_queue_size
    Rails.configuration.x.dashboard_top_items_queue_size
  end
end
