# == Schema Information
#
# Table name: resources
#
#  id              :integer          not null, primary key
#  identifier      :string           not null
#  title           :string           default("Unknown"), not null
#  resource_type   :enum             not null
#  canonical_id    :string           not null
#  source_uri      :string
#  context_id      :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_resources_on_context_id                        (context_id)
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#

RSpec.describe Resource do
  subject { build(:resource) }

  it { is_expected.to validate_presence_of(:identifier) }
  it { is_expected.to validate_uniqueness_of(:identifier) }

  it { is_expected.to validate_presence_of(:resource_type) }

  it { is_expected.to validate_presence_of(:canonical_id) }
  it { is_expected.to validate_uniqueness_of(:canonical_id).scoped_to(:organization_id) } 
end
