RSpec.describe SerializableResource do
  include_context 'serializable object'

  let(:object) { build_stubbed(:resource) }

  let(:approved_representations) do
    build_stubbed_list(:representation,2)
  end

  before do
    allow(object).
      to receive_messages({
        context_title: 'Website',
        approved_representations: approved_representations
      })
  end

  subject do
    serialized.fetch(:attributes)
  end
  
  it { is_expected.to include(canonical_id: object.canonical_id) }
end
