RSpec.describe UserPolicy do
  let(:user_record) do 
    double(:user,class: User,id: org_user.id)
  end

  subject { UserPolicy.new(org_user,user_record) }

  context 'as a user, with own record' do
    include_context "editor organization user"

    it { is_expected.to permit_action(:index)          }
    it { is_expected.to permit_action(:show)           }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_new_and_create_actions  }
    it { is_expected.to forbid_action(:destroy)        }
  end

  context "as a user, when attempting ot access another user's record" do
    include_context "editor organization user"

    before do
      allow(user_record).to receive_messages(id: 123456)
    end

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy)        }
  end

  context 'as an admin' do
    include_context "admin organization user"

    it { is_expected.to permit_new_and_create_actions  }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy)        }
  end

  context "as an owner" do
    include_context "staff organization user"

    it { is_expected.to permit_action(:index)          }
    it { is_expected.to permit_action(:show)           }
    it { is_expected.to permit_new_and_create_actions  }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy)        }

    context "when accessing another user's record" do
      before do
        allow(user_record).to receive_messages(id: 123456)
      end

      it { is_expected.to permit_action(:destroy)       }
    end
  end
end
