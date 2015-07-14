class AssignmentsController < ApplicationController
  before_filter :admin
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :next_image

  respond_to :html, :js, :json

  # GET /assignments
  def index
    @assignments = Assignment.all.page params[:page]
  end

  # GET /assignments/1
  def show
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
    @assignment.image = Image.find(params[:image_id]) if params[:image_id]
    @assignment.user = Image.find(params[:user_id]) if params[:user_id]
  end

  # GET /assignments/1/edit
  def edit
    @image = @assignment.image
  end

  # POST /assignments
  def create
    @assignment = Assignment.new(assignment_params)

    if @assignment.save
      #redirect_to @assignment, notice: 'Assignment was successfully created.'
      redirect_to root_path, notice: 'Assignment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /assignments/1
  def update
    if @assignment.update(assignment_params)
      #redirect_to @assignment, notice: 'Assignment was successfully updated.'
      redirect_to root_path, notice: 'Assignment was successfully created.'
    else
      render :edit
    end
  end

  # DELETE /assignments/1
  def destroy
    @assignment.destroy
    redirect_to assignments_url, notice: 'Assignment was successfully destroyed.'
  end

  # POST /assignments/bulk
  def bulk
    assignments = assignments_params[:assignments]

    success_count = 0
    fail_count = 0
    errors = ""

    assignments.each do |k, a|
      puts a
      assignment = Assignment.new(user_id: a[:user_id], image_id: a[:image_id])
      if assignment.save
        success_count += 1
      else
        fail_count += 1
        errors += assignment.errors.full_messages.collect{|m| m + ".  "}.join()
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
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def assignment_params
      params.require(:assignment).permit(:user_id, :image_id)
    end

    def assignments_params
      params.permit(:assignments => [:user_id, :image_id])
    end

    def next_image
      @next_image = Image.limit(1).unassigned
      @next_image = nil if @next_image.empty?
    end
end
