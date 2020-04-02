# frozen_string_literal: true

RSpec.shared_context "serializable object" do
  let(:serialized) do
    described_class.new({
      object:      object,
      url_helpers: Rails.application.routes.url_helpers,
    }).as_jsonapi
  end
end
