RSpec.describe DescriptionPolicy do
  include_context "viewer organization user"

  let(:description) do 
    double(:description,class: Description,user_id: org_user.id)
  end

  subject { DescriptionPolicy.new(org_user,description) }

  it { is_expected.to permit_action(:index)          }
  it { is_expected.to permit_action(:show)           }
  it { is_expected.to forbid_new_and_create_actions  }
  it { is_expected.to forbid_edit_and_update_actions }
  it { is_expected.to forbid_action(:destroy)        }

  context "as an author" do
    include_context "author organization user"

    it { is_expected.to permit_action(:index)          }
    it { is_expected.to permit_action(:show)           }
    it { is_expected.to permit_new_and_create_actions  }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy)        }

    context "with a description the user does not own" do
      before do
        allow(description).to receive_messages(user_id: 12345)
      end

      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action(:destroy)        }
    end
  end

  context "as an editor" do
    include_context "editor organization user"

    it { is_expected.to permit_action(:index)          }
    it { is_expected.to permit_action(:show)           }
    it { is_expected.to permit_new_and_create_actions  }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy)        }

    context "with a description the user does not own" do
      before do
        allow(description).to receive_messages(user_id: 12345)
      end

      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to permit_action(:destroy)        }
    end
  end
end
