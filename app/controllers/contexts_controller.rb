# Handles requests for Context information
# @see Context
class ContextsController < ApplicationController
  # NOTE currently there are no controls for who can access Contexts, see https://github.com/coyote-team/coyote/issues/116
  before_action :set_context, only: %i[show edit update destroy]
  before_action :get_contexts, only: %i[index]

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
    self.context = current_organization.contexts.new
  end

  # GET /contexts/1/edit
  def edit
  end

  # POST /contexts
  api :POST, "contexts/:id", "Create a context"
  param_group :context
  def create
    self.context = current_organization.contexts.new(context_params)

    if context.save
      logger.info "Created #{context}"
      redirect_to [current_organization,context], notice: 'Context was successfully created.'
    else
      logger.warn "Unable to create context: '#{context.error_sentence}'"
      render :new
    end
  end

  # PATCH/PUT /contexts/1
  api :PUT, "contexts/:id", "Update a context"
  param_group :context
  def update
    if context.update(context_params)
      redirect_to [current_organization,context], notice: 'Context was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /contexts/1
  api :DELETE, "contexts/:id", "Delete a context"
  def destroy
    context.destroy
    redirect_to organization_contexts_url(current_organization), notice: 'Context was successfully destroyed.'
  end

  private

  attr_accessor :user, :context, :contexts

  def set_context
    self.context = current_organization.contexts.find(params[:id])
  end

  def context_params
    params.require(:context).permit(:title)
  end
end
