RSpec.describe InvitationPolicy do
  include_context "editor organization user"

  subject { InvitationPolicy.new(org_user,Invitation) }

  it { is_expected.to forbid_action(:index)          }
  it { is_expected.to forbid_action(:show)           }
  it { is_expected.to forbid_new_and_create_actions  }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy)        }

  context "as an admin" do
    subject do 
      InvitationPolicy.new(org_user,build_stubbed(:invitation,:editor))
    end

    include_context "admin organization user"

    it { is_expected.to forbid_action(:index)          }
    it { is_expected.to forbid_action(:show)           }
    it { is_expected.to permit_new_and_create_actions  }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy)        }
  end

  context "as an admin attempting to mint another admin" do
    subject do 
      InvitationPolicy.new(org_user,build_stubbed(:invitation,:admin))
    end

    include_context "admin organization user"

    it { is_expected.to forbid_action(:index)          }
    it { is_expected.to forbid_action(:show)           }
    it { is_expected.to permit_action(:new)            }
    it { is_expected.to permit_action(:create)         }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy)        }
  end

  context "as an owner" do
    subject do 
      InvitationPolicy.new(org_user,build_stubbed(:invitation,:owner))
    end

    include_context "owner organization user"

    it { is_expected.to forbid_action(:index)          }
    it { is_expected.to forbid_action(:show)           }
    it { is_expected.to permit_new_and_create_actions  }
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy)        }
  end
end
