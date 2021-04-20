# frozen_string_literal: true

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[show destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access, only: %i[show destroy]

  helper_method :assignment, :assigned_users

  # POST /assignments
  def create
    resource_ids = assignment_params.values_at(:resource_ids, :resource_id).tap(&:compact!)
    resources = current_organization.resources.where(id: resource_ids)

    assignments = resources.map { |resource|
      assignment = resource.assignments.find_or_initialize_by(user_id: assigned_user.id)
      assignment.infer_status!
    }

    logger.info "Created '#{assignments}'"
    flash[:notice] = "Created #{assignments.count} #{"assignment".pluralize(assignments.count)}"

    redirect_back fallback_location: [current_organization]
  end

  # DELETE /assignments/1
  def destroy
    if assignment.update(status: :deleted)
      logger.info "Deleted #{assignment}"
      redirect_back fallback_location: assignments_path, notice: assignment.user_id == current_user.id ? "You've unassigned yourself" : "The assignment has been deleted."
    else
      logger.warn "Unable to delete #{assignment}: '#{assignment.error_sentence}'"
      flash[:error] = "We were unable to delete the assignment"
      redirect_to :back
    end
  end

  # GET /assignments
  def index
    if params[:membership_id]
      @membership = current_organization.memberships.find(params[:membership_id])
      @assignments = current_organization.assignments.active.where(user_id: @membership.user_id).by_priority
      render :member_index
    else
      assignments = current_organization.assignments.active.by_user_name
      memberships = current_organization.memberships.index_by(&:user_id)

      self.assigned_users = assignments.each_with_object({}) do |assignment, hash|
        membership = memberships[assignment.user_id]
        hash[membership] ||= []
        hash[membership].push(assignment)
        hash
      end
    end
  end

  # GET /assignments/new
  def new
  end

  # GET /assignments/1
  def show
  end

  private

  attr_accessor :assigned_users, :assignment

  def assigned_user
    current_organization.users.find(assignment_params[:user_id])
  end

  def assignment_params
    params.require(:assignment).permit(:user_id, :resource_id, resource_ids: [])
  end

  def authorize_general_access
    authorize Assignment
  end

  def authorize_unit_access
    authorize(assignment)
  end

  def set_assignment
    self.assignment = current_organization.assignments.find(params[:id])
  end
end
