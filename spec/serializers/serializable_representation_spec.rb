RSpec.describe SerializableRepresentation do
  include_context 'serializable object'

  let(:object) do
    build_stubbed(:representation, resource_id: 100)
  end

  before do
    allow(object).
      to receive_messages({
        author_name: 'John Doe',
        license_title: 'CC1',
        metum_title: 'Alt'
      })
  end

  subject do
    serialized.fetch(:attributes)
  end

  it { is_expected.to include(author: 'John Doe', text: object.text) }
end
