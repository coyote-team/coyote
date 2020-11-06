# frozen_string_literal: true

# Provides read-only access to view the profile of individual users
class UsersController < ApplicationController
  skip_before_action :require_user, only: %i[create new]

  before_action :authorize_access, only: :show
  before_action :require_invitation, only: %i[create new]

  helper_method :invitation, :user

  def create
    if user.update(new_user_attributes.except(:token))
      logger.info "Successfully completed registration of #{user} for #{invitation}"
      invitation.redeem!
      log_user_in user,
        notice: "Welcome to Coyote! You are now a member of the #{invitation.organization_name} organization.",
        path:   organization_path(invitation.organization)
    else
      logger.warn "Unable to complete registration for #{user} due to '#{user.error_sentence}'"
      render :new
    end
  end

  def edit
  end

  def new
    flash.now[:notice] = "Welcome to Coyote! After completing this form, you will become a member of the #{invitation.organization_name} organization."
  end

  def show
    self.user = User.find(params[:id])
  end

  def update
    if user.update(update_user_attributes)
      redirect_to_return_path notice: "Your profile has been updated"
    else
      flash[:error] = "Your profile could not be saved!"
      render :edit
    end
  end

  private

  attr_accessor :invitation, :user

  def authorize_access
    authorize(user)
  end

  def new_user_attributes
    params.require(:user).permit(:email, :password, :password_confirmation, :token)
  end

  def pundit_user
    # necessary to override ApplicationController's method here because in this controller we may not be dealing with a particular organization
    @pundit_user ||= Coyote::OrganizationUser.new(current_user, nil)
  end

  def representations_scope
    return @representations_scope if defined? @representations_scope
    representations = Representation.where(author_id: user.id).includes(:metum)
    representations = representations.includes(:resource).references(:resource).where(resources: {organization_id: current_organization.id}) if current_organization?
    @representations_scope = representations.by_status_and_ordinality
  end
  helper_method :representations_scope

  def require_invitation
    token = request.get? ? params.require(:token) : new_user_attributes[:token]
    self.invitation = Invitation.find_by!(token: token)
    self.user = invitation.recipient_user

    if invitation.redeemed?
      logger.error "Attempt to use previously-redeemed #{invitation}"
      redirect_to new_session_path, alert: %(We're sorry, but that invitation has already been used.)
      false
    else
      true
    end
  end

  def require_user
    self.user = current_user
    super
  end

  def update_user_attributes
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :password,
      :password_confirmation,
      :current_password,
    )
  end
end
