# frozen_string_literal: true

RSpec.shared_context "with webhooks" do
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

def create_redirection_context(code)
  RSpec.shared_context "with #{code} redirected webhooks" do
    let(:resource_group) { create(:resource_group, webhook_uri: "http://www.example.com/webhook/goes/here") }
    let(:redirect_location) { "http://www.example.com/webhook/redirected/url" }

    around do |example|
      VCR.use_cassette("#{code}_redirected_webhooks", record: :new_episodes) do
        example.run
      end
    end

    let!(:request) {
      stub_request(:post, resource_group.webhook_uri).to_return(
        status:  code,
        headers: {
          'Location': redirect_location,
        },
      )

      stub_request(:post, redirect_location).to_return(
        body:   "REDIRECTION_FOLLOWED",
        status: 200,
      )
    }
  end
end

[301, 302, 303, 307, 308].each { |code| create_redirection_context(code) }

RSpec.shared_context "without webhooks" do
  around do |example|
    Sidekiq::Testing.fake! do
      example.run
      expect(NotifyWebhookWorker.jobs).to be_empty
    end
  end
end
