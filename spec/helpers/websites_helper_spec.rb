RSpec.describe WebsitesHelper do
  specify do
    expect(helper.strategies_collection).to include(%w[MCA Coyote::Strategies::MCA])
  end
end
