# == Schema Information
#
# Table name: resources
#
#  id                    :bigint(8)        not null, primary key
#  identifier            :string           not null
#  title                 :string           default("Unknown"), not null
#  resource_type         :enum             not null
#  canonical_id          :string           not null
#  source_uri            :string
#  resource_group_id     :bigint(8)        not null
#  organization_id       :bigint(8)        not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  representations_count :integer          default(0), not null
#  priority_flag         :boolean          default(FALSE), not null
#  host_uris             :string           default([]), not null, is an Array
#  ordinality            :integer
#
# Indexes
#
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#  index_resources_on_resource_group_id                 (resource_group_id)
#

RSpec.describe Resource do
  let(:source_uri) { 'http://example.com/100.jpg' }

  subject do
    build(:resource, :image, title: 'Mona Lisa', identifier: 'abc123', source_uri: source_uri)
  end

  it { is_expected.to validate_presence_of(:resource_type) }

  it { is_expected.to validate_uniqueness_of(:identifier) }

  specify { expect(subject.label).to eq("Mona Lisa (abc123)") }

  specify do
    expect(subject).to have_many(:subject_resource_links).class_name(:ResourceLink).with_foreign_key(:subject_resource_id).inverse_of(:subject_resource)
  end

  specify do
    expect(subject).to have_many(:object_resource_links).class_name(:ResourceLink).with_foreign_key(:object_resource_id).inverse_of(:object_resource)
  end

  specify do
    expect(subject).to be_viewable
  end

  context 'without the presence of a source URI' do
    subject do
      build(:resource, :image, source_uri: '')
    end

    specify do
      expect(subject).not_to be_viewable
    end
  end

  context 'with a non-image resource type' do
    subject do
      build(:resource, :physical_object)
    end

    specify do
      expect(subject).not_to be_viewable
    end
  end

  context '#related_resources' do
    # this test requires the database as rspec stubs don't completely replicate has_many behaviors
    let!(:resource_link) do
      create(:resource_link, verb: 'hasPart')
    end

    let(:subject_resource) { resource_link.subject_resource }
    let(:object_resource) { resource_link.object_resource }

    it 'returns correctly labeled predicates' do
      expect(subject_resource.related_resources).to eq([['hasPart', resource_link, object_resource]])
      expect(object_resource.related_resources).to eq([['isPartOf', resource_link, subject_resource]])
    end
  end

  context "::has_approved_representations" do
    let!(:approved_resource) { create(:resource) }
    let!(:approved_representation) { create(:representation, resource: approved_resource, status: "approved") }

    let!(:unapproved_resource) { create(:resource) }
    let!(:unapproved_representation) { create(:representation, resource: approved_resource, status: "not_approved") }

    it "returns resources that have approved represents" do
      expect(Resource.with_approved_representations).to eq([approved_resource])
    end
  end

  context 'when saved' do
    it 'sets a unique identifier based on the title' do
      resource = build(:resource, identifier: "", title: "This is a test, isn't it?! YES!")
      expect(resource.identifier).to be_blank
      resource.save!
      expect(resource.identifier).to eq("this-is-a-test-isn-t-it-yes")

      resource_2 = create(:resource, identifier: "", title: "This is a test, isn't it?! YES!")
      expect(resource_2.identifier).to eq("this-is-a-test-isn-t-it-yes-2")
    end

    it 'sets a unique canonical id' do
      resource = build(:resource)
      expect(resource.canonical_id).to be_blank
      resource.save!
      expect(resource.canonical_id).to be_present
    end

    it 'does not set a canonical ID if one is given' do
      resource = build(:resource)
      resource.canonical_id = '123'
      resource.save!
      expect(resource.canonical_id).to eq('123')
    end
  end
end
