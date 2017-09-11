module Coyote
  # Encapsulates a particular user acting within a particular organization, using a role defined via the Membership model.
  # Used by Pundit.
  # @see User
  # @see Membership
  # @see Organization
  # @see https://github.com/elabs/pundit#additional-context
  class OrganizationUser
    # @!attribute [r] staff?
    #   @return [Boolean] whether or not the user is a Coyote staff member with cross-organizational authority
    # @!attribute [r] id
    #   @return [Integer] database ID of the underlying User object
    delegate :id, :staff?, :to => :user

    # @param user [User] the user who is acting
    # @param organization [Organization] the organization being acted upon/within
    def initialize(user,organization)
      @user = user
      @organization = organization
    end

    # @!attribute [r] guest?
    #   @return [Boolean] is the user at least a guest for this organization?
    # @!attribute [r] viewer?
    #   @return [Boolean] is the user at least a viewer for this organization?
    #   @note Each role in inherits the power of the roles below/before it in the hierarchy
    # @!attribute [r] author?
    #   @return [Boolean] is the user at least an author for this organization?
    #   @note (see #viewer?)
    # @!attribute [r] editor?
    #   @return [Boolean] is the user at least an editor for this organization?
    #   @note (see #viewer?)
    # @!attribute [r] admin?
    #   @return [Boolean] is the user at least an admin for this organization?
    #   @note (see #viewer?)
    # @!attribute [r] owner?
    #   @return [Boolean] is the user at least an owner of this organization?
    #   @note (see #viewer?)
    Coyote::Membership.each_role do |_,test_role_name,test_role_rank|
      define_method :"#{test_role_name}?" do
        return true if staff? # staff members automatically have all admin owner powers regardless of whatever role they nominally hold in an organization
        role_rank >= test_role_rank
      end
    end

    # @return [Symbol] the name of the role held by this user in the current organization
    def role
      @role ||= (user.memberships.find_by(organization: organization)&.role || :none).to_sym
    end

    def role_rank
      @role_rank ||= Coyote::Membership.role_rank(role)
    end

    private

    attr_reader :user, :organization
  end
end
