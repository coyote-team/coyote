# frozen_string_literal: true

# == Schema Information
#
# Table name: meta
#
#  id              :integer          not null, primary key
#  instructions    :text             default(""), not null
#  is_required     :boolean          default(FALSE), not null
#  name            :citext           not null
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :bigint           not null
#
# Indexes
#
#  index_meta_on_organization_id           (organization_id)
#  index_meta_on_organization_id_and_name  (organization_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#

RSpec.describe Metum do
  subject { build(:metum) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:instructions) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:organization_id) }
end
