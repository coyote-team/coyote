RSpec.describe MembershipPolicy do
  let(:org_user) do 
    double(:organization_user,admin?: false,id: 2,role_rank: 1)
  end

  let(:record) do 
    double(:record,user_id: 1,class: Membership,role_rank: 0)
  end

  let(:scope) { double(:scope) }

  subject { MembershipPolicy.new(org_user,record) }

  it { is_expected.to permit_action(:index)          }
  it { is_expected.to permit_action(:show)           }
  it { is_expected.to forbid_new_and_create_actions  }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy)        }
  
  specify { expect(subject.scope).to eq(Membership) }

  context 'as an admin' do
    before do
      allow(org_user).to receive_messages(admin?: true)
    end

    context "when accessing another user's membership" do
      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to permit_action(:destroy)        }
    end

    context 'when accessing the membership of a role with the same rank' do
      before do
        allow(record).to receive_messages(role_rank: org_user.role_rank)
      end

      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action(:destroy)        }
    end

    context 'when accessing the membership of a role with a higher rank' do
      before do
        allow(record).to receive_messages(role_rank: org_user.role_rank + 1)
      end

      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action(:destroy)        }
    end
  end

  context "as an admin attempting to change self membership" do
    before do
      allow(org_user).to receive_messages(admin?: true,id: 1)
    end

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy)        }
  end
end
