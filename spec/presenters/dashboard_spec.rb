# frozen_string_literal: true

RSpec.describe Dashboard, type: :integration do
  subject do
    described_class.new(user, organization)
  end

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, organization: organization, first_name: "Z", last_name: "Z") }
  let!(:other_user) { create(:user, organization: organization, first_name: "A", last_name: "Z") }

  describe "with no resources or representations" do
    it "returns correct values" do # rubocop:disable RSpec/ExampleLength
      aggregate_failures do
        expect(subject.current_user_approved_representation_count).to eq(0)
        expect(subject.current_user_assigned_items_count).to eq(0)
        expect(subject.current_user_represented_resources_count).to eq(0)
        expect(subject.current_user_representation_count).to eq(0)
        expect(subject.current_user_queue_empty?).to be true
        expect(subject.current_user_top_assigned_items_queue).to eq([])
        expect(subject.current_user_unapproved_representation_count).to eq(0)

        expect(subject.organization_approved_representation_count).to eq(0)
        expect(subject.organization_assigned_count).to eq(0)
        expect(subject.organization_represented_resource_count).to eq(0)
        expect(subject.organization_representation_count).to eq(0)
        expect(subject.organization_resource_count).to eq(0)
        expect(subject.organization_latest_resource_timestamp).to be nil
        expect(subject.organization_open_assignment_count).to eq(0)
        expect(subject.organization_ready_to_review_count).to eq(0)
        expect(subject.organization_top_ready_to_review_items_queue).to eq([])
        expect(subject.organization_top_unassigned_items_queue).to eq([])
        expect(subject.organization_top_unrepresented_items_queue).to eq([])
        expect(subject.organization_unassigned_count).to eq(0)
        expect(subject.organization_unassigned_unrepresented_count).to eq(0)
        expect(subject.organization_unrepresented_count).to eq(0)
        expect(subject.organization_users).to eq([other_user, user])
      end
    end
  end

  describe "with resources and representations" do
    let(:resource_group) { create(:resource_group, organization: organization) }
    let!(:ready_to_review_representation_of_third_resource_by_user) do
      create(:representation, :ready_to_review, resource: third_resource, author: user)
    end
    let(:latest_timestamp) { 1.hour.from_now }

    let!(:resources) do
      create_list(:resource, 5, organization: organization, resource_groups: [resource_group])
    end

    let(:first_resource) { resources[0] }
    let(:second_resource) { resources[1] }
    let(:third_resource) { resources[2] }
    let(:unassigned_resource) { resources[3] }
    let(:other_user_resource) { resources[4] }

    let(:resource_for_other_organization) { create(:resource) }

    before do
      create(:representation, :approved, resource: first_resource, author: user)
      create(:assignment, resource: second_resource, user: user)

      create(:assignment, resource: other_user_resource, user: other_user)
      third_resource.update!(created_at: latest_timestamp)
    end

    it "returns correct values" do # rubocop:disable RSpec/ExampleLength
      aggregate_failures do
        expect(subject.organization_resource_count).to eq(5)
        expect(subject.organization_representation_count).to eq(2)
        expect(subject.organization_represented_resource_count).to eq(2)
        expect(subject.organization_approved_representation_count).to eq(1)
        expect(subject.organization_ready_to_review_count).to eq(1)
        expect(subject.organization_assigned_count).to eq(4)
        expect(subject.organization_open_assignment_count).to eq(2)
        expect(subject.organization_unassigned_count).to eq(1)
        expect(subject.organization_latest_resource_timestamp).to be_within(1.second).of(latest_timestamp)
        expect(subject.organization_top_ready_to_review_items_queue).to eq([ready_to_review_representation_of_third_resource_by_user])
        expect(subject.organization_top_unassigned_items_queue).to eq([unassigned_resource])
        expect(subject.organization_top_unrepresented_items_queue).to match_array([second_resource, unassigned_resource, other_user_resource])
        expect(subject.organization_unassigned_unrepresented_count).to eq(1)
        expect(subject.organization_unrepresented_count).to eq(3)

        expect(subject.current_user_approved_representation_count).to eq(1)
        expect(subject.current_user_assigned_items_count).to eq(1)
        expect(subject.current_user_represented_resources_count).to eq(2)
        expect(subject.current_user_representation_count).to eq(2)
        expect(subject.current_user_queue_empty?).to be false
        expect(subject.current_user_top_assigned_items_queue).to match_array([second_resource])
        expect(subject.current_user_unapproved_representation_count).to eq(0)
      end
    end
  end
end
