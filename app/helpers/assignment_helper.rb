# frozen_string_literal: true

module AssignmentHelper
  def assignable_users
    @assignable_users ||= policy(Assignment).scope_users(current_organization.active_users.can_author.sorted)
  end

  def assignment_link_for(resource, options = {})
    return unless can_only_assign_to_self?
    assignment = resource.assigned_to?(current_user)
    if assignment
      link_to(t("assignment.destroy_for_self"), assignment_path(assignment), combine_options(options, "data-method" => :delete))
    else
      simple_form_for :assignment, url: assignments_path, html: {class: "field form--inline"} do |f|
        safe_join([
          f.hidden_field(:resource_id, as: :hidden, value: resource.id),
          f.hidden_field(:user_id, value: current_user.id),
          f.submit(t("assignment.create_for_self"), combine_options(options, aria: {label: "Assign resource ##{resource.id}"})),
        ])
      end
    end
  end

  def can_assign?
    can?(:create, Assignment)
  end

  def can_only_assign_to_self?
    can_assign? && assignable_users == [current_user]
  end
end
