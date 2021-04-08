# frozen_string_literal: true

RSpec.shared_context "with a serializable object" do
  let(:serialized) do
    described_class.new({
      object:      object,
      url_helpers: Rails.application.routes.url_helpers,
    }).as_jsonapi
  end
end
