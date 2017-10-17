module Coyote
  # Utility functions for managing Organizational Roles
  module Membership
    # Enumerates the roles available in the Postgres 'user_role' ENUM, for use with ActiveRecord::Base.enum
    ROLES = {
      guest:  'guest',
      viewer: 'viewer',
      author: 'author',
      editor: 'editor',
      admin:  'admin',
      owner:  'owner'
    }.freeze

    module_function

    # Iterates through all possible Membership roles
    # @yieldparam role_human_name [String]
    # @yieldparam role_name [Symbol]
    # @yieldparam role_rank [Integer] for sorting and comparison purposes; higher numbers are associated with higher-ranking/more-powerful roles
    def self.each_role
      ROLES.each_key do |role_name|
        yield role_name.to_s.titleize, role_name, role_rank(role_name) if block_given?
      end
    end

    # @return [Array<Symbol>] list of role names
    def self.role_names
      ROLES.keys
    end

    # @return [Integer] for sorting and comparison purposes; higher numbers are associated with higher-ranking/more-powerful roles
    def self.role_rank(role_name)
      return role_names.size + 1 if role_name == :staff
      role_names.index(role_name.to_sym) || -1
    end
  end
end
