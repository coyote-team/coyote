RSpec.describe WebsitePolicy do
  let(:org_user) { double(:organization_user) }
  let(:website) { double(:website,class: Website) }
  let(:scope) { double(:scope) }

  subject { WebsitePolicy.new(org_user,website) }

  it { is_expected.to forbid_action(:index)          }
  it { is_expected.to forbid_action(:show)           }
  it { is_expected.to forbid_new_and_create_actions  }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy)        }
  
  specify { expect(subject.scope).to eq(Website) }
end

