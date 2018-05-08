class AssignmentsController < ApplicationController
  before_action :set_assignment,           only: %i[show destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show destroy]

  helper_method :assignment, :assigned_users, :next_resource, :users, :resources

  # GET /assignments
  def index
    assignments = current_organization.assignments.to_a

    assignments.sort_by! do |a|
      [a.user_last_name, a.user_email].tap(&:compact!).first
    end

    memberships = current_organization.memberships.index_by(&:user_id)

    self.assigned_users = assignments.each_with_object(Hash.new(0)) do |assignment, hash|
      membership = memberships[assignment.user_id]
      if membership
        hash[membership] = hash[membership] + 1
      end
      hash
    end
  end

  # GET /assignments/1
  def show
  end

  # GET /assignments/new
  def new
  end

  # POST /assignments
  def create
    resource_ids = assignment_params.values_at(:resource_ids, :resource_id).tap(&:compact!)
    resources = current_organization.resources.where(id: resource_ids)

    assignments = resources.map do |resource|
      Assignment.find_or_create_by!(resource: resource, user: assigned_user)
    end

    logger.info "Created '#{assignments}'"
    flash[:notice] = "Created #{assignments.count} #{'assignment'.pluralize(assignments.count)}"

    redirect_back fallback_location: [current_organization]
  end

  # DELETE /assignments/1
  def destroy
    if assignment.destroy
      logger.info "Deleted #{assignment}"
      redirect_to organization_assignments_url(current_organization), notice: 'Assignment was successfully destroyed.'
    else
      logger.warn "Unable to delete #{assignment}: '#{assignment.error_sentence}'"
      flash[:error] = "We were unable to delete the assignment"
      redirect_to :back
    end
  end

  private

  attr_accessor :assigned_users, :assignment

  def set_assignment
    self.assignment = current_organization.assignments.find(params[:id])
  end

  def users
    current_organization.users.sorted
  end

  def resources
    current_organization.resources
  end

  def assignment_params
    params.require(:assignment).permit(:user_id, :resource_id, resource_ids: [])
  end

  def next_resource
    current_organization.resources.unassigned.first
  end

  def authorize_general_access
    authorize Assignment
  end

  def authorize_unit_access
    authorize(assignment)
  end

  def assigned_user
    current_organization.users.find(assignment_params[:user_id])
  end

  def assigned_resource
    current_organization.resources.find(assignment_params[:resource_id])
  end
end
