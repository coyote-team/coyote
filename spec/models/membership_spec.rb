# frozen_string_literal: true

# == Schema Information
#
# Table name: memberships
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE)
#  role            :enum             default("guest"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_memberships_on_user_id_and_organization_id  (user_id,organization_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

RSpec.describe Membership do
  subject { create(:membership) }

  it { is_expected.to validate_presence_of(:role) }

  it { is_expected.not_to be_last_owner }

  specify do
    expect(subject.role_rank).to eq(0)
  end

  describe "when the membership represents an organization owner" do
    subject { create(:membership, :owner) }

    it { is_expected.to be_last_owner }

    specify do
      expect(subject.role_rank).to be > 0
    end

    describe "and there are other owner memberships" do
      let!(:other_owner) do
        create(:membership, :owner, organization: subject.organization)
      end

      it { is_expected.not_to be_last_owner }
    end
  end
end
