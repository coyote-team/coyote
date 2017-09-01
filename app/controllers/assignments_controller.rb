class AssignmentsController < ApplicationController
  before_action :authorize_admin!
  before_action :set_assignment, only: %i[show edit update destroy]
  before_action :set_next_image, only: %i[show]
  before_action :set_users, only: %i[new edit]
  before_action :set_images, only: %i[new edit]

  helper_method :image, :assignment, :assignments, :next_image, :users, :images

  respond_to :html, :js, :json

  # GET /assignments
  def index
    self.assignments = current_organization.assignments.page(params[:page])
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
    assigned_user = current_organization.users.find(assignment_params[:user_id])
    assigned_image = current_organization.images.find(assignment_params[:image_id])

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
    if assignment.update(assignment_params)
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
        redirect_to assignments_url, notice: 'Assignment was successfully destroyed.'
      end
    else
      logger.warn "Unable to delete #{assignment}: '#{assignment.error_sentence}'"
      flash[:error] = "We were unable to delete the assignment"
      redirect_to :back 
    end
  end

  # POST /assignments/bulk
  def bulk
    assignments = assignments_params[:assignments]

    success_count = 0
    fail_count = 0
    errors = ""

    assignments.each do |k, a|
      assignment = Assignment.new(user_id: a[:user_id], image_id: a[:image_id])

      if assignment.save
        success_count += 1
      else
        fail_count += 1
        #errors += assignment.errors.full_messages.collect{|m| m + ".  "}.join()
      end
    end

    if fail_count == 0 and success_count > 0
      flash[:success] = success_count.to_s + " assignments created."
    elsif fail_count == 0 and success_count == 0
      flash[:notice] = "No assignments created."
    else
      error = fail_count.to_s + " assignments failed.  " + errors  
      if success_count > 0 
        error +=  success_count.to_s + " assignments created."
      end
      flash[:error]  = error
    end
    render nothing: true
  end

  private
  
  attr_accessor :image, :assignment, :assignments, :next_image, :users, :images

  # Use callbacks to share common setup or constraints between actions.
  def set_assignment
    self.assignment = current_organization.assignments.find(params[:id])
  end

  def set_users
    self.users = current_organization.users.sorted
  end

  def set_images
    self.images = current_organization.images
  end

  def assignment_params
    params.require(:assignment).permit(:user_id,:image_id)
  end

  def assignments_params
    params.permit(assignments: %i[user_id image_id])
  end

  def set_next_image
    self.next_image = current_organization.images.unassigned.first
  end
end
