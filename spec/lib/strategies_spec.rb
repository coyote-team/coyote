require "coyote/strategies"

RSpec.describe Coyote::Strategies do
  it ".all returns a list of eager-loaded strategy classes" do
    expect(Coyote::Strategies.all).to match_array([Coyote::Strategies::MCA])
  end
end
