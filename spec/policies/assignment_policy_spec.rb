RSpec.describe AssignmentPolicy do
  let(:org_user) { double(:organization_user) }
  let(:record) { double(:record,class: Assignment) }
  let(:scope) { double(:scope) }

  subject { AssignmentPolicy.new(org_user,record) }

  it { is_expected.to forbid_action(:index)          }
  it { is_expected.to forbid_action(:show)           }
  it { is_expected.to forbid_new_and_create_actions  }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy)        }
  
  specify { expect(subject.scope).to eq(Assignment) }
end
