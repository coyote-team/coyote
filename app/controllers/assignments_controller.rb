class AssignmentsController < ApplicationController
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]

  helper_method :image, :assignment, :assignments, :next_image, :users, :images

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
    assignment.image = current_organization.images.find(params[:image_id]) if params[:image_id]
    assignment.user  = current_organization.users.find(params[:user_id])   if params[:user_id]
  end

  # GET /assignments/1/edit
  def edit
    self.image = assignment.image
  end

  # POST /assignments
  def create
    self.assignment = Assignment.create(user: assigned_user,image: assigned_image)

    if assignment.valid?
      logger.info "Created '#{assignment}'"
      flash[:notice] = "#{assignment} was successfully created."
    else
      logger.warn "Unable to create assignment: '#{assignment.error_sentence}'"
    end

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

      if request.xhr?
        render nothing: true
      else
        redirect_to organization_assignments_url(current_organization), notice: 'Assignment was successfully destroyed.'
      end
    else
      logger.warn "Unable to delete #{assignment}: '#{assignment.error_sentence}'"
      flash[:error] = "We were unable to delete the assignment"
      redirect_to :back 
    end
  end

  private
  
  attr_writer :assignment, :image

  def assignment
    @assignment ||= current_organization.assignments.find(params[:id])
  end

  def assignments
    current_organization.assignments.by_created_at.page(params[:page])
  end

  def users
    current_organization.users.sorted
  end

  def images
    current_organization.images
  end

  def assignment_params
    params.require(:assignment).permit(:user_id,:image_id)
  end

  def next_image
    current_organization.images.unassigned.first
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

  def assigned_image 
    current_organization.images.find(assignment_params[:image_id])
  end
end
