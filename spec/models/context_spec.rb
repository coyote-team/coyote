# == Schema Information
#
# Table name: contexts
#
#  id              :integer          not null, primary key
#  title           :string           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer          not null
#
# Indexes
#
#  index_contexts_on_organization_id_and_title  (organization_id,title) UNIQUE
#

RSpec.describe Context do
  subject { build(:context) }

  it { is_expected.to validate_uniqueness_of(:title).scoped_to(:organization_id) } 
end
