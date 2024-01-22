# frozen_string_literal: true

# Used to rescue form errors that would otherwise raise an exception and display the standard rails 500 error page
# Needed to rescue from resources controller create action for identical/invalid source URIs and Canonical IDs
# Can add additional rescue_from statements as needed for other controllers/forms
module FormErrors
  extend ActiveSupport::Concern

  included do
  rescue_from ActiveRecord::RecordNotUnique, with: :not_unique_response
  rescue_from URI::InvalidURIError, with: :invalid_uri_response
  end

  private 

  def not_unique_response(e)
    response = check_unique_error(e)
    resource.errors.add(:base, response)
    logger.warn "Unable to create resource due to '#{e.message}'"
    render :new, status: :unprocessable_entity
  end

  def check_unique_error(e)
    if e.message.include?("canonical_id")
      "The Canonical ID is already in use for this organization."
    elsif e.message.include?("source_uri")
      "The Source URI is already in use for this organization."
    end
  end

  def invalid_uri_response(e)
    response = "The Source URI is invalid."
    resource.errors.add(:base, response)
    logger.warn "Unable to create resource due to '#{e.message}'"
    render :new, status: :unprocessable_entity
  end
end