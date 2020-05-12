# frozen_string_literal: true

RSpec.describe SerializableOrganization do
  subject do
    described_class.new(object: organization).as_jsonapi.fetch(:attributes)
  end

  let(:organization) { build_stubbed(:organization) }

  it { is_expected.to include(name: organization.name) }
end
