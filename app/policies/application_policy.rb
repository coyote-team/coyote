# frozen_string_literal: true

# Base class for Coyote authorization policies. Uses Pundit.
# @abstract intended to be subclassed for each ActiveRecord class that needs policy protection
# @see https://github.com/elabs/pundit
class ApplicationPolicy
  delegate :organization, to: :organization_user

  # @raise [Pundit::NotAuthorizedError] if organization_user is nil
  # @param organization_user [organization_user]
  # @param record [ActiveRecord::Base]
  def initialize(organization_user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless organization_user

    @organization_user = organization_user
    @record = record
  end

  # @return [false]
  def create?
    false
  end

  # @return [false]
  def destroy?
    false
  end

  # @return (see #update?)
  def edit?
    update?
  end

  # @return [false]
  def index?
    false
  end

  # @return (see #create?)
  def new?
    create?
  end

  # @return [ActiveRecord::Base] the scope upon which to base ActiveRecord queries, based on the class of the record passed in
  # @see https://github.com/elabs/pundit#scopes
  # @see ApplicationPolicy::Scope
  def scope
    Pundit.policy_scope!(organization_user, model)
  end

  # @return [false]
  def show?
    false
  end

  # @return [false]
  def update?
    false
  end

  # @private only used for pundit-matchers spec error reporting
  def user
    organization_user
  end

  # Restricts ActiveRecord queries using scopes based on the user's access permissions
  class Scope
    # @!attribute [r] organization_user
    #   @return [Coyote::OrganizationUser]
    # @!attribute [r] scope
    #   @return [ActiveRecord::Associations::CollectionProxy] the scope upon which to base ActiveRecord queries
    # attr_reader :organization_user, :scope

    # @param organization_user [Coyote::OrganizationUser]
    # @param scope [ActiveRecord::Associations::CollectionProxy] the scope upon which to base ActiveRecord queries, which this class may scope further
    def initialize(organization_user, scope)
      @organization_user = organization_user
      @scope = scope
    end

    # @return [ActiveRecord::Associations::CollectionProxy] the scope upon which to base ActiveRecord queries, restricted to records the organization user can access
    def resolve
      scope
    end

    private

    # @private only used for pundit-matchers specs
    attr_reader :organization_user, :scope
  end

  private

  attr_reader :organization_user, :record

  def instance
    record.is_a?(Class) ? nil : record
  end

  def model
    record.is_a?(Class) ? record : instance&.class
  end
end
