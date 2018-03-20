# == Schema Information
#
# Table name: resource_groups
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_resource_groups_on_organization_id_and_title  (organization_id,title) UNIQUE
#

RSpec.describe ResourceGroup do
  subject { build(:resource_group) }

  it { is_expected.to validate_uniqueness_of(:title).scoped_to(:organization_id) }
end
