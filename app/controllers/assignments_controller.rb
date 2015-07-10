class AssignmentsController < ApplicationController
  before_filter :admin
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :next_image

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
  end

  # GET /assignments/1/edit
  def edit
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def assignment_params
      params.require(:assignment).permit(:user_id, :image_id)
    end
    def next_image
      @next_image = Image.limit(1).unassigned
      @next_image = nil if @next_image.empty?
    end
end
