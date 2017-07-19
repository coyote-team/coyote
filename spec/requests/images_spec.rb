# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  path               :string(255)
#  website_id         :integer
#  group_id           :integer
#  created_at         :datetime
#  updated_at         :datetime
#  canonical_id       :string(255)
#  assignments_count  :integer          default(0)
#  descriptions_count :integer          default(0)
#  title              :text(65535)
#  priority           :boolean          default(FALSE)
#  status_code        :integer          default(0)
#  page_urls          :text(65535)
#
# Indexes
#
#  index_images_on_group_id    (group_id)
#  index_images_on_website_id  (website_id)
#

RSpec.describe "Image API requests", :type => :request do
  let(:user) { create(:user) }
  let(:image ) { create(:image) }

  describe 'GET /images/:id.json' do |meta|
    it 'returns image record' do
      get "/images/#{image.id}.json", {}.to_json, api_user_headers(user)
      expect_json_keys(%i(id canonical_id  path  page_urls  priority  group_id  website_id  created_at  updated_at url alt title long))
    end
  end

  describe 'GET /images.json' do
    before(:each) do
      @images = []
      5.times do
        image = create(:image)
        @images << image
      end
    end

    it 'returns all image records to user' do
      get "/images.json", {}.to_json, api_user_headers(user)
      expect_json_keys([:_metadata, :records])
    end
  end
end
