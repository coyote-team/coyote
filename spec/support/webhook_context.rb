# frozen_string_literal: true

RSpec.shared_context "webhooks" do
  let(:resource_group) { create(:resource_group, webhook_uri: "http://www.example.com/webhook/goes/here") }

  around do |example|
    VCR.use_cassette("webhooks", record: :new_episodes) do
      example.run
    end
  end

  let!(:request) {
    stub_request(:post, resource_group.webhook_uri).to_return(
      body:   "OKAY",
      status: 200,
    )
  }
end

RSpec.shared_context "without webhooks" do
  around do |example|
    Cloudtasker::Testing.fake! do
      example.run
      expect(NotifyWebhookWorker.jobs).to be_empty
    end
  end
end
