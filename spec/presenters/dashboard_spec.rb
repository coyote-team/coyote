RSpec.describe Dashboard, :type => :integration do
  let(:organization) { create(:organization) }
  let(:user) { create(:user,organization: organization) }
  let(:other_user) { create(:user,organization: organization) }

  subject do
    Dashboard.new(user,organization)
  end

  context "with no images or descriptions" do
    scenario "returns correct values" do
      aggregate_failures do
        expect(subject.current_user_approved_description_count).to eq(0)
        expect(subject.current_user_assigned_items_count).to eq(0)
        expect(subject.current_user_described_images_count).to eq(0)
        expect(subject.current_user_description_count).to eq(0)
        expect(subject.current_user_queue_empty?).to be true
        expect(subject.current_user_top_assigned_items_queue).to eq([])
        expect(subject.current_user_unapproved_description_count).to eq(0)

        expect(subject.organization_approved_description_count).to eq(0)
        expect(subject.organization_assigned_count).to eq(0)
        expect(subject.organization_described_image_count).to eq(0)
        expect(subject.organization_description_count).to eq(0)
        expect(subject.organization_image_count).to eq(0)
        expect(subject.organization_latest_image_timestamp).to be nil
        expect(subject.organization_open_assignment_count).to eq(0)
        expect(subject.organization_ready_to_review_count).to eq(0)
        expect(subject.organization_top_ready_to_review_items_queue).to eq([])
        expect(subject.organization_top_unassigned_items_queue).to eq([])
        expect(subject.organization_top_undescribed_items_queue).to eq([])
        expect(subject.organization_unassigned_count).to eq(0)
        expect(subject.organization_unassigned_undescribed_count).to eq(0)
        expect(subject.organization_undescribed_count).to eq(0)
        expect(subject.organization_users).to eq([user,other_user])
      end
    end
  end

  context "with images and descriptions" do
    let(:website) { create(:website,organization: organization) }
    let(:context) { create(:context,organization: organization) }

    let!(:images) do 
      create_list(:image,5,organization: organization,website: website,context: context)
    end

    let(:first_image)      { images[0] }
    let(:second_image)     { images[1] }
    let(:third_image)      { images[2] }
    let(:unassigned_image) { images[3] }
    let(:other_user_image) { images[4] }

    let(:image_for_other_organization) { create(:image) }

    let!(:approved_description_of_first_image_by_user) do
      create(:description,:approved,image: first_image,user: user)
    end

    let!(:image_assignments) do
      [first_image,second_image,third_image].each do |image|
        create(:assignment,image: image,user: user)
      end

      create(:assignment,image: other_user_image,user: other_user)
    end

    let!(:ready_to_review_description_of_third_image_by_user) do
      create(:description,:ready_to_review,image: third_image,user: user)
    end

    let(:latest_timestamp) { 1.hour.from_now }
    
    before do
      third_image.update_attributes!(created_at: latest_timestamp)
    end

    scenario "returns correct values" do
      aggregate_failures do
        expect(subject.organization_image_count).to eq(5)
        expect(subject.organization_description_count).to eq(2)
        expect(subject.organization_described_image_count).to eq(2)
        expect(subject.organization_approved_description_count).to eq(1)
        expect(subject.organization_ready_to_review_count).to eq(1)
        expect(subject.organization_assigned_count).to eq(4)
        expect(subject.organization_open_assignment_count).to eq(2)
        expect(subject.organization_unassigned_count).to eq(1)
        expect(subject.organization_latest_image_timestamp).to eq(latest_timestamp)
        expect(subject.organization_top_ready_to_review_items_queue).to eq([ready_to_review_description_of_third_image_by_user])
        expect(subject.organization_top_unassigned_items_queue).to eq([unassigned_image])
        expect(subject.organization_top_undescribed_items_queue).to match_array([second_image,unassigned_image,other_user_image])
        expect(subject.organization_unassigned_undescribed_count).to eq(1)
        expect(subject.organization_undescribed_count).to eq(3)
        
        expect(subject.current_user_approved_description_count).to eq(1)
        expect(subject.current_user_assigned_items_count).to eq(1)
        expect(subject.current_user_described_images_count).to eq(2)
        expect(subject.current_user_description_count).to eq(2)
        expect(subject.current_user_queue_empty?).to be false
        expect(subject.current_user_top_assigned_items_queue).to match_array([second_image])
        expect(subject.current_user_unapproved_description_count).to eq(0)
      end
    end
  end
end
