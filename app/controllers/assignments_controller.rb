class AssignmentsController < ApplicationController
  before_action :set_assignment,           only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]

  helper_method :assignment, :assignments, :next_resource, :users, :resources

  respond_to :html, :js, :json

  # GET /assignments
  def index
  end

  # GET /assignments/1
  def show
  end

  # GET /assignments/new
  def new
    self.assignment = current_organization.assignments.new
  end

  # GET /assignments/1/edit
  def edit
  end

  # POST /assignments
  def create
    self.assignment = Assignment.find_or_create_by!(user: assigned_user,resource: assigned_resource)

    logger.info "Created '#{assignment}'"
    flash[:notice] = "#{assignment} was successfully created."

    redirect_to [current_organization,assignment]
  end

  # PATCH/PUT /assignments/1
  def update
    assignment.user = assigned_user

    if assignment.save
      redirect_to [current_organization,assignment], notice: 'Assignment was successfully updated.'
    else
      logger.warn "Unable to update #{assignment}: '#{assignment.error_sentence}'"
      render :edit
    end
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
  
  attr_accessor :assignment

  def set_assignment
    self.assignment = current_organization.assignments.find(params[:id])
  end

  def assignments
    current_organization.assignments.by_created_at.page(params[:page])
  end

  def users
    current_organization.users.sorted
  end

  def resources
    current_organization.resources
  end

  def assignment_params
    params.require(:assignment).permit(:user_id,:resource_id)
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
