RSpec.describe ApplicationHelper do
  let(:current_user) { build_stubbed(:user,first_name: "Hal") }
  let(:resource_uri) { 'http://example.com/1.png' }

  subject do
    Struct.new(:current_user) {
      include ApplicationHelper
    }.new(current_user)
  end

  context '#resource_link_target with an image resource' do
    let(:resource) do 
      build_stubbed(:resource,:image)
    end

    before do
      allow(resource).to receive(:as_viewable).and_yield(resource_uri)
    end

    specify do
      link = helper.resource_link_target(resource,'resource_100',alt: 'some text')
      expect(link).to eq(%(<img alt="some text" aria-describedby="resource_100" src="#{resource_uri}" />))
    end
  end

  context '#resource_link_target without image resource' do
    let(:resource) do 
      build_stubbed(:resource,:sound) 
    end

    before do
      allow(resource).to receive_messages(as_viewable: nil)
    end

    specify do
      expect(helper.resource_link_target(resource,'resource_100')).to eq('Mona Lisa (sound)')
    end
  end

  context "#welcome_message" do
    it "greets a logged-in user" do
      expect(subject.welcome_message).to match(/Welcome.+Hal/)
    end

    it "greets non-logged-in users" do
      assign(:current_user,nil)
      expect(subject.welcome_message).to match(/Welcome/)
    end
  end
end
