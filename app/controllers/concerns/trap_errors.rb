# frozen_string_literal: true

module TrapErrors
  def self.included(base)
    base.rescue_from ActionController::ParameterMissing, with: :maybe_trap_unprocessable_entity
    base.rescue_from ActiveRecord::RecordNotFound, with: :maybe_trap_not_found
    base.rescue_from Pundit::NotAuthorizedError, with: :maybe_trap_forbidden
  end

  def maybe_trap_forbidden(exception)
    raise exception unless trap_errors?
    trap_forbidden(exception)
  end

  def maybe_trap_not_found(exception)
    raise exception unless trap_errors?
    trap_not_found(exception)
  end

  def maybe_trap_unprocessable_entity(exception)
    raise exception unless trap_errors?
    trap_unprocessable_entity(exception)
  end

  def trap_errors?
    return @trap_errors if defined? @trap_errors
    @trap_errors = Credentials.fetch(:app, :rescue_from_errors) { false }
  end
end
