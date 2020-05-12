# frozen_string_literal: true

RSpec.describe SerializableResource do
  include_context "serializable object"

  subject do
    serialized.fetch(:attributes)
  end

  let(:object) { build_stubbed(:resource) }

  let(:approved_representations) do
    build_stubbed_list(:representation, 2)
  end

  before do
    allow(object)
      .to receive_messages({
        resource_group_name:      "Website",
        approved_representations: approved_representations,
      })
  end

  it { is_expected.to include(id: object.id) }
  it { is_expected.to include(canonical_id: object.canonical_id) }
end
