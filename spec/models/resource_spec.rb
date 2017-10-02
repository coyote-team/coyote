# == Schema Information
#
# Table name: resources
#
#  id              :integer          not null, primary key
#  identifier      :string           not null
#  title           :string           default("Unknown"), not null
#  resource_type   :enum             not null
#  canonical_id    :string           not null
#  source_uri      :string
#  context_id      :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_resources_on_context_id                        (context_id)
#  index_resources_on_identifier                        (identifier) UNIQUE
#  index_resources_on_organization_id                   (organization_id)
#  index_resources_on_organization_id_and_canonical_id  (organization_id,canonical_id) UNIQUE
#

RSpec.describe Resource do
  let(:source_uri) { 'http://example.com/100.jpg' }

  subject do 
    build(:resource,:image,source_uri: source_uri)
  end

  it { is_expected.to validate_presence_of(:identifier) }
  it { is_expected.to validate_presence_of(:resource_type) }
  it { is_expected.to validate_presence_of(:canonical_id) }

  it { is_expected.to validate_uniqueness_of(:identifier) }
  it { is_expected.to validate_uniqueness_of(:canonical_id).scoped_to(:organization_id) } 

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
end
