# Handles requests for Context information
# @see Context
class ContextsController < ApplicationController
  before_action :set_context, only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[new index create]
  before_action :authorize_unit_access,    only: %i[show edit update destroy]

  helper_method :context, :contexts

  # GET /contexts
  def index
  end

  # GET /contexts/1
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
  def update
    if context.update(context_params)
      redirect_to [current_organization,context], notice: 'Context was successfully updated.'
    else
      logger.warn "Unable to update #{context}: #{context.error_sentence}"
      render :edit
    end
  end

  # DELETE /contexts/1
  def destroy
    if context.destroy
      flash[:notice] = 'Context was successfully destroyed.'
    else
      msg = "Unable to destroy #{context}: #{context.error_sentence}"
      logger.warn msg
      flash[:error] = msg
    end

    redirect_to organization_contexts_url(current_organization)
  end

  private

  attr_accessor :context

  def set_context
    @context = current_organization.contexts.find(params[:id])
  end

  def contexts
    @contexts ||= current_organization.contexts
  end

  def context_params
    params.require(:context).permit(:title)
  end

  def authorize_general_access
    authorize Context
  end

  def authorize_unit_access
    authorize(context)
  end
end
