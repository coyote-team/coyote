RSpec.describe OrganizationPolicy do
  include_context "admin organization user"

  let(:description) do 
    double(:description,class: Description,user_id: org_user.id)
  end

  subject { OrganizationPolicy.new(org_user,description) }

  it { is_expected.to permit_action(:index)          }
  it { is_expected.to permit_action(:show)           }
  it { is_expected.to permit_new_and_create_actions  }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy)        }

  context "as an owner" do
    include_context "owner organization user"

    it { is_expected.to permit_action(:index)          }
    it { is_expected.to permit_action(:show)           }
    it { is_expected.to permit_new_and_create_actions  }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy)        }
  end
end
