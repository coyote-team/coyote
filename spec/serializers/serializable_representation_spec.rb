# frozen_string_literal: true

RSpec.describe SerializableRepresentation do
  include_context "serializable object"

  subject do
    serialized.fetch(:attributes)
  end

  let(:object) do
    build_stubbed(:representation, resource_id: 100)
  end

  before do
    allow(object)
      .to receive_messages({
        author_name:  "John Doe",
        license_name: "CC1",
        metum_name:   "Alt",
      })
  end

  it { is_expected.to include(author: "John Doe", text: object.text) }
end
