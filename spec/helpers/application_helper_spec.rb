# frozen_string_literal: true

RSpec.describe ApplicationHelper do
  subject do
    Struct.new(:current_user) {
      include ApplicationHelper
    }.new(current_user)
  end

  let(:current_user) { build_stubbed(:user, first_name: "Hal") }
  let(:resource_uri) { "http://example.com/1.png" }

  describe "#resource_link_target with an image resource" do
    let(:resource) do
      build_stubbed(:resource)
    end

    before do
      # allow(resource).to receive(:viewable?).and_return(true)
      allow(resource).to receive(:source_uri).and_return(resource_uri)
    end

    specify do
      link = helper.resource_link_target(resource, id: "resource_100", alt: "some text")
      expect(link).to match(/src="#{resource_uri}"/)
    end
  end

  describe "#welcome_message" do
    it "greets a logged-in user" do
      expect(subject.welcome_message).to match(/Welcome.+Hal/)
    end

    it "greets non-logged-in users" do
      assign(:current_user, nil)
      expect(subject.welcome_message).to match(/Welcome/)
    end
  end
end
