RSpec.describe 'API root' do
  context 'with an authentication token' do
    include_context 'API author user'

    scenario 'requests succeed' do
      get api_root_path, headers: auth_headers
      expect(response).to be_success

      json_data.fetch(:links).tap do |links|
        expect(URI.parse(links.fetch(:self)).path).to eq('/api/v1')
        expect(URI.parse(links.fetch(:resources)).path).to eq('/api/v1/resources')
      end
    end
  end

  it 'requires authentication token' do
    get api_root_path
    expect(response).to be_unauthorized
    expect(json_data).to have_key(:errors)
  end
end
