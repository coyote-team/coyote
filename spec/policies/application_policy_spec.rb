RSpec.describe ApplicationPolicy do
  let(:org_user) { double(:organization_user) }
  let(:record) { double(:record,class: User) }
  let(:scope) { double(:scope) }

  subject { ApplicationPolicy.new(org_user,record) }

  it { is_expected.to forbid_action(:index)          }
  it { is_expected.to forbid_action(:show)           }
  it { is_expected.to forbid_new_and_create_actions  }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy)        }

  specify { expect(subject.scope).to eq(User) }
end
