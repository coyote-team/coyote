RSpec.describe Membership, :type => :integration do
  subject { create(:membership) }

  it { is_expected.not_to be_last_owner }

  context 'when the membership represents an organization owner' do
    subject { create(:membership,:owner) }
    it { is_expected.to be_last_owner }

    context 'and there are other owner memberships' do
      let!(:other_owner) do 
        create(:membership,:owner,organization: subject.organization) 
      end

      it { is_expected.not_to be_last_owner }
    end
  end
end
