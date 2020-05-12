# frozen_string_literal: true

# Manages CRUD operations for adding/removing users from an Organization
# @see Membership
class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[show edit update destroy]
  before_action :authorize_general_access, only: %i[index]
  before_action :authorize_unit_access, only: %i[edit update destroy]

  helper_method :membership, :organization_users

  # @note will not allow an organization owner to delete their membership, if there are no remaining owners
  def destroy
    if membership.last_owner?
      logger.warn "#{current_user} attempted to remove him- or herself from #{current_organization}, but the actionw was prevented since there are no other owners of that organization"
      err_msg = "We cannot let you remove yourself as the last owner of the '#{current_organization.name}' organization. Please choose another user to be an owner, or delete the organization itself."

      redirect_back fallback_location: organization_memberships_url, alert: err_msg
      return :redirect_after_preventing_destruction # avoid leaking nil
    end

    membership.update_attribute(:active, false)
    redirect_back fallback_location: organization_memberships_url, notice: "#{membership.user} has been removed from #{current_organization.name}"
  end

  def edit
  end

  def index
  end

  # @raise [Coyote::SecurityError] if the user with a certain rank attempts to promote another user above that rank
  def update
    new_role = membership_params[:role]

    if Coyote::Membership.role_rank(new_role) > organization_user.role_rank
      err_msg = "#{organization_user} attempted to promote #{membership.user} to role '#{new_role}', but is not allowed to promote any roles higher than his or her own ('#{organization_user.role}')"
      logger.error err_msg
      raise Coyote::SecurityError, err_msg
    end

    if membership.update(membership_params)
      flash[:notice] = "Membership of #{membership.user} was successfully updated."
      redirect_back fallback_location: organization_memberships_url
    else
      logger.warn "Unable to update #{membership}: '#{membership.errors.full_messages.to_sentence}'"
      render :edit
    end
  end

  private

  attr_accessor :membership

  def authorize_general_access
    authorize Membership
  end

  def authorize_unit_access
    authorize(membership)
  end

  def membership_params
    params.require(:membership).permit(:role)
  end

  def organization_users
    @organization_users ||= begin
                              current_organization.users.sorted.map do |u|
                                Coyote::OrganizationUser.new(u, current_organization)
                              end
                            end
  end

  def set_membership
    self.membership = current_organization.memberships.find(params[:id])
  end
end
