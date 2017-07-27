class GroupsController < ApplicationController
  # NOTE currently there are no controls for who can access Groups, see https://github.com/coyote-team/coyote/issues/116
  before_filter :users
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def_param_group :group do
    param :group, Hash do
      param :title,  String, required: true
      param :created_at,    DateTime
      param :updated_at,    DateTime
    end
  end

  # GET /groups
  api :GET, "groups", "Get an index of groups"
  def index
    @groups = Group.all
  end

  # GET /groups/1
  api :GET, "groups/:id", "Get a group"
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  api :POST, "groups/:id", "Create a group"
  param_group :group
  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /groups/1
  api :PUT, "groups/:id", "Update a group"
  param_group :group
  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /groups/1
  api :DELETE, "groups/:id", "Delete a group"
  def destroy
    @group.destroy
    redirect_to groups_url, notice: 'Group was successfully destroyed.'
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def group_params
    params.require(:group).permit(:title)
  end
end
