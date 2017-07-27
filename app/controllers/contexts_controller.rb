# Handles requests for Context information
# @see Context
class ContextsController < ApplicationController
  # NOTE currently there are no controls for who can access Contexts, see https://github.com/coyote-team/coyote/issues/116
  before_action :set_context, only: %i[show edit update destroy]
  before_filter :get_contexts, only: %i[index]

  helper_method :context, :contexts, :users

  def_param_group :context do
    param :context, Hash do
      param :title,  String, required: true
      param :created_at,    DateTime
      param :updated_at,    DateTime
    end
  end

  # GET /contexts
  api :GET, "contexts", "Get an index of contexts"
  def index
  end

  # GET /contexts/1
  api :GET, "contexts/:id", "Get a context"
  def show
  end

  # GET /contexts/new
  def new
    self.context = Context.new
  end

  # GET /contexts/1/edit
  def edit
  end

  # POST /contexts
  api :POST, "contexts/:id", "Create a context"
  param_group :context
  def create
    self.context = Context.new(context_params)

    if context.save
      redirect_to context, notice: 'Context was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /contexts/1
  api :PUT, "contexts/:id", "Update a context"
  param_group :context
  def update
    if context.update(context_params)
      redirect_to context, notice: 'Context was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /contexts/1
  api :DELETE, "contexts/:id", "Delete a context"
  def destroy
    context.destroy
    redirect_to contexts_url, notice: 'Context was successfully destroyed.'
  end

  private

  attr_accessor :user, :context, :contexts

  # Use callbacks to share common setup or constraints between actions.
  def set_context
    self.context = Context.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def context_params
    params.require(:context).permit(:title)
  end
end
