# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  title      :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_on_title  (title) UNIQUE
#

RSpec.describe OrganizationsController do
  skip
end
