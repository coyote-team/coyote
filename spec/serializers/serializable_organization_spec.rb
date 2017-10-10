RSpec.describe SerializableOrganization do
  let(:organization) { build_stubbed(:organization) }

  subject do
    described_class.new(object: organization).as_jsonapi.fetch(:attributes)
  end
  
  it { is_expected.to include(title: organization.title) }
end
