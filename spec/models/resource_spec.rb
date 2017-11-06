# == Schema Information
#
# Table name: resources
#
#  id                    :integer          not null, primary key
#  identifier            :string           not null
#  title                 :string           default("Unknown"), not null
#  resource_type         :enum             not null
#  canonical_id          :string           not null
#  source_uri            :string
#  context_id            :integer          not null
#  organization_id       :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  representations_count :integer          default(0), not null
#  priority_flag         :boolean          default(FALSE), not null
#
# Indexes
#
#  index_resources_on_context_id                        (context_id)
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#  index_resources_on_priority_flag                     (priority_flag)
#  index_resources_on_representations_count             (representations_count)
#

RSpec.describe Resource do
  let(:source_uri) { 'http://example.com/100.jpg' }

  subject do 
    build(:resource,:image,title: 'Mona Lisa',identifier: 'abc123',source_uri: source_uri)
  end

  it { is_expected.to validate_presence_of(:identifier) }
  it { is_expected.to validate_presence_of(:resource_type) }
  it { is_expected.to validate_presence_of(:canonical_id) }

  it { is_expected.to validate_uniqueness_of(:identifier) }
  it { is_expected.to validate_uniqueness_of(:canonical_id).scoped_to(:organization_id) } 

  specify { expect(subject.label).to eq("Mona Lisa (abc123)") }

  specify do
    expect(subject).to have_many(:subject_resource_links).class_name(:ResourceLink).with_foreign_key(:subject_resource_id).inverse_of(:subject_resource)
  end

  specify do
    expect(subject).to have_many(:object_resource_links).class_name(:ResourceLink).with_foreign_key(:object_resource_id).inverse_of(:object_resource)
  end

  specify do
    expect { |b| subject.as_viewable(&b) }.to yield_with_args(source_uri)
  end

  context 'without the presence of a source URI' do
    subject do 
      build(:resource,:image,source_uri: '')
    end

    specify do
      expect { |b| subject.as_viewable(&b) }.not_to yield_control
    end
  end

  context 'with a non-image resource type' do
    subject do
      build(:resource,:physical_object)
    end

    specify do
      expect { |b| subject.as_viewable(&b) }.not_to yield_control
    end
  end

  context '#related_resources' do
    # this test requires the database as rspec stubs don't completely replicate has_many behaviors
    let!(:resource_link) do 
      create(:resource_link,verb: 'hasPart')
    end

    let(:subject_resource) { resource_link.subject_resource }
    let(:object_resource) { resource_link.object_resource }

    it 'returns correctly labeled predicates' do
      expect(subject_resource.related_resources).to eq([['hasPart',resource_link,object_resource]])
      expect(object_resource.related_resources).to eq([['isPartOf',resource_link,subject_resource]])
    end
  end
end
